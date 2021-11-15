//
//  Created by Iurii Sorokin on 03.11.2021.
//

import SwiftSyntax
import Foundation

struct MutationTestingResult {
    let total: Int
    let killed: Int
}

struct MutationTestingIterationReport {

    struct Mutation {
        let path: String
        let point: MutationPoint
        let result: MutationResult
    }

    let number: Int
    let started: Date
    let duration: TimeInterval
    let mutations: [Mutation]
    let report: ExecutionReport
}


protocol MutationTestingStepDelegate: MutanusSequanceStepDelegate {
    func iterationStated(index: Int)
    func iterationFinished(duration: TimeInterval, result: ExecutionReport)
}

final class MutationTestingStep: MutanusSequanceStep {

    let executor: Executor
    let resultParser: MutationResultParser
    let fileManager: MutanusFileManger
    let reportCompiler: ReportCompiler

    weak var stepDelegate: MutationTestingStepDelegate?

    init(
        executor: Executor,
        resultParser: MutationResultParser,
        fileManager: MutanusFileManger,
        reportCompiler: ReportCompiler,
        delegate: MutationTestingStepDelegate?
    ) {
        self.fileManager = fileManager
        self.executor = executor
        self.resultParser = resultParser
        self.stepDelegate = delegate
        self.reportCompiler = reportCompiler
    }

    // MARK: - MutanusSequanceStep

    typealias Context = MutantsInfo
    typealias Result = MutationTestingResult

    var delegate: MutanusSequanceStepDelegate? { stepDelegate }
    var next: AnyPerformsAction<Result>?

    func executeStep(_ context: Context) throws -> Result {

        var iterationResults: [MutationTestingIterationReport] = []
        iterationResults.reserveCapacity(context.maxFileCount)

        var killedCount = 0
        var mutatingFilePaths: [String] = context.mutants.keys.map { $0 }

        for i in 0..<3 {

            let iterationStartTime = Date()

            stepDelegate?.iterationStated(index: i)

            let logURL = fileManager.createLogFile(name: "Iteration\(i+1).txt")

            var mutations: [(path: String, point: MutationPoint)] = []

            for (path, mutantInfo) in context.mutants {
                let mutationPoints = mutantInfo.points

                guard i < mutationPoints.count else { continue }

                insertMutant(to: path, mutationPoint: mutationPoints[i], within: mutantInfo.source)

                mutations.append((path, mutationPoints[i]))
            }

            try executor.executeProccess(logURL: logURL)

            let iterationDuration = iterationStartTime.distance(to: Date())

            let executionResult = resultParser.recognizeResult(fileURL: logURL, paths: mutatingFilePaths)

            for (key, value) in context.mutants where i == (value.points.count - 1) {
                mutatingFilePaths.removeAll { $0 == key }
                fileManager.restoreFileFromBackup(path: key)
            }

            let iterationResult = MutationTestingIterationReport(
                number: i,
                started: iterationStartTime,
                duration: iterationDuration,
                mutations: mutations.map {
                    .init(
                        path: $0.path,
                        point: $0.point,
                        result: executionResult.killed.contains($0.path) ? .killed : .survived
                    )},
                report: executionResult
            )

            iterationResults.append(iterationResult)
            stepDelegate?.iterationFinished(duration: iterationDuration, result: executionResult)
            killedCount += executionResult.killed.count
        }

        reportCompiler.iterationsFinished(iterationResults)

        return MutationTestingResult(
            total: context.totalCount,
            killed: killedCount
        )
    }
}

private extension MutationTestingStep {

    func insertMutant(to path: String, mutationPoint: MutationPoint, within sourceCode: SourceFileSyntax) {
        let mutatedSource = mutationPoint.sourceTransformation(sourceCode).mutatedSource

        try! mutatedSource.description.write(toFile: path, atomically: true, encoding: .utf8)
    }
}
