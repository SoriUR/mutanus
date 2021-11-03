//
//  FindMutantsStep.swift
//  Mutanus
//
//  Created by Iurii Sorokin on 03.11.2021.
//

import Foundation
import SwiftSyntax

final class FindMutantsStep: MutanusSequanceStep {
    typealias Context = [String]
    typealias Result = [String: (SourceFileSyntax, [MutationPoint])]

    var next: AnyPerformsAction<Result>?

    func performStep(_ context: Context) throws -> Result {
        var result = [String: (SourceFileSyntax, [MutationPoint])]()

        context.forEach { path in
            guard let source = sourceCode(fromFileAt: path) else {
                return
            }

            let mutationPoints = findMutationPoints(in: source).sorted(by: filePositionOrder)

//            mutationPoints.forEach {
//                let snapshot = $0.mutationOperator(source.code).mutationSnapshot
//                print("\($0.position.line):\($0.position.column) \(snapshot.description)")
//            }

            result[path] = (source.code, mutationPoints)
        }

        return result
    }

    private func findMutationPoints(in file: SourceCodeInfo) -> [MutationPoint] {
        MutationOperator.Id.allCases.accumulate(into: []) { newMutationPoints, mutationOperatorId in

            let visitor = mutationOperatorId.visitor(file.asSourceFileInfo)

            visitor.walk(file.code)

            return newMutationPoints + visitor.positionsOfToken.map { MutationPoint(
                mutationOperatorId: mutationOperatorId,
                filePath: file.path,
                position: $0
            )}
        }
    }

    func sourceCode(fromFileAt path: String) -> SourceCodeInfo? {
        let url = URL(fileURLWithPath: path)
        return (try? SyntaxParser.parse(url)).map { SourceCodeInfo(path: url.absoluteString, code: $0) }
    }

    private func filePositionOrder(lhs: MutationPoint, rhs: MutationPoint) -> Bool {
        return lhs.position.line < rhs.position.line &&
            lhs.position.column < rhs.position.column
    }
}
