//
//  Created by Iurii Sorokin on 03.11.2021.
//

import SwiftSyntax
import Foundation

struct MutationTestingResult {
    let total: Int
    let survived: Int
    let killed: Int
}

final class MutationTestingStep: MutanusSequanceStep {

    let executor: Executor
    let resultParser: MutationResultParser
    let fileManager: MutanusFileManger
    let reportCompiler: ReportCompiler

    init(
        executor: Executor,
        resultParser: MutationResultParser,
        fileManager: MutanusFileManger,
        reportCompiler: ReportCompiler,
        delegate: MutanusSequanceStepDelegate?
    ) {
        self.fileManager = fileManager
        self.executor = executor
        self.resultParser = resultParser
        self.delegate = delegate
        self.reportCompiler = reportCompiler
    }

    // MARK: - MutanusSequanceStep

    typealias Context = MutantsInfo
    typealias Result = MutationTestingResult

    var delegate: MutanusSequanceStepDelegate?
    var next: AnyPerformsAction<Result>?

    func executeStep(_ context: Context) throws -> Result {

        var mutationResults = [ExecutionResult]()
        mutationResults.reserveCapacity(context.maxFileCount)
        var iterationResults: [MutationTestingIterationReport] = []

        var survivedCount = 0
        var killedCount = 0
        var mutatingPaths: [String] = context.mutants.keys.map { $0 }

        for i in 0..<3 {

            let iterationStartTime = Date()

            Logger.logEvent(.mutationIterationStarted(index: i+1))

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

            let executionResult = resultParser.recognizeResult(fileURL: logURL, paths: mutatingPaths)
            mutationResults.append(executionResult.result)

            for (key, value) in context.mutants where i == (value.points.count - 1) {
                mutatingPaths.removeAll { $0 == key }
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

            Logger.logEvent(.mutationIterationFinished(
                duration: iterationDuration,
                result: executionResult.result,
                killed: executionResult.killed.count,
                survived: executionResult.survived.count
            ))

            survivedCount += executionResult.survived.count
            killedCount += executionResult.killed.count
        }

        reportCompiler.iterationsFinished(iterationResults)

        return MutationTestingResult(
            total: context.totalCount,
            survived: survivedCount,
            killed: killedCount
        )
    }
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

private extension MutationTestingStep {

    func insertMutant(to path: String, mutationPoint: MutationPoint, within sourceCode: SourceFileSyntax) {
        let mutatedSource = mutationPoint.sourceTransformation(sourceCode).mutatedSource

        try! mutatedSource.description.write(toFile: path, atomically: true, encoding: .utf8)
    }
}
