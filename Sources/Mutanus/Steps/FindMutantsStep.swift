//
//  FindMutantsStep.swift
//  Mutanus
//
//  Created by Iurii Sorokin on 03.11.2021.
//

import Foundation
import SwiftSyntax
import SwiftSyntaxParser

final class FindMutantsStep: MutanusSequenceStep {

    let reportCompiler: ReportCompiler?

    init(
        reportCompiler: ReportCompiler? = nil,
        delegate: MutanusSequenceStepDelegate? = nil
    ) {
        self.reportCompiler = reportCompiler
        self.delegate = delegate
    }

    // MARK: - MutanusSequenceStep

    typealias Context = [String]
    typealias Result = MutantsInfo

    var next: AnyPerformsAction<Result>?
    weak var delegate: MutanusSequenceStepDelegate?

    func executeStep(_ context: Context) throws -> Result {
        var result = [String: (SourceFileSyntax, [MutationPoint])]()

        context.forEach { path in
            guard let source = sourceCode(fromFileAt: path) else {
                return
            }

            let mutationPoints = findMutationPoints(in: source).sorted(by: filePositionOrder)

            result[path] = (source.code, mutationPoints)
        }

        let filtered = result.filter { $0.value.1.count > 0 }

        guard !filtered.isEmpty else {
            fatalError("no mutants")
        }

        var maxCount = Int.min
        var totalCount: Int = 0

        filtered.forEach {
            let mutantsCount = $0.value.1.count
            maxCount = mutantsCount > maxCount ? mutantsCount : maxCount
            totalCount += mutantsCount
        }

        let info = MutantsInfo(
            mutants: filtered,
            totalCount: totalCount,
            maxFileCount: maxCount
        )

        reportCompiler?.extractedSources(info)

        return info
    }

    private func findMutationPoints(in file: SourceCodeInfo) -> [MutationPoint] {
        MutationOperator.allCases.accumulate(into: []) { newMutationPoints, mutationOperatorId in

            let visitor = mutationOperatorId.visitor(file.asSourceFileInfo)

            visitor.walk(file.code)

            return newMutationPoints + visitor.positionsOfToken.map { MutationPoint(
                operator: mutationOperatorId,
                position: $0
            )}
        }
    }

    private func filePositionOrder(lhs: MutationPoint, rhs: MutationPoint) -> Bool {
        return lhs.position.line < rhs.position.line && lhs.position.column < rhs.position.column
    }
}

func sourceCode(fromFileAt path: String) -> SourceCodeInfo? {
    let url = URL(fileURLWithPath: path)
    return (try? SyntaxParser.parse(url)).map { SourceCodeInfo(path: url.absoluteString, code: $0) }
}

struct MutantsInfo {
    let mutants: [String: (source: SourceFileSyntax, points: [MutationPoint])]
    let totalCount: Int
    let maxFileCount: Int
}
