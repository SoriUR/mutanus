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

    init(
        executor: Executor,
        resultParser: MutationResultParser,
        fileManager: MutanusFileManger,
        delegate: MutanusSequanceStepDelegate?
    ) {
        self.fileManager = fileManager
        self.executor = executor
        self.resultParser = resultParser
        self.delegate = delegate
    }

    // MARK: - MutanusSequanceStep

    typealias Context = MutantsInfo
    typealias Result = MutationTestingResult

    var delegate: MutanusSequanceStepDelegate?
    var next: AnyPerformsAction<Result>?

    func executeStep(_ context: Context) throws -> Result {

        var mutationResults = [ExecutionResult]()
        mutationResults.reserveCapacity(context.maxFileCount)

        var survivedCount = 0
        var killedCount = 0
        var mutatingPaths: [String] = context.mutants.keys.map { $0 }

        for i in 0..<context.maxFileCount {

            let iterationStartTime = Date()

            Logger.logEvent(.mutationIterationStarted(index: i+1))

            let logURL = fileManager.createLogFile(name: "Iteration\(i+1).txt")

            for mutantInfo in context.mutants.values {
                let mutationPoints = mutantInfo.1

                guard i < mutationPoints.count else { continue }

                let sourceCode = mutantInfo.0
                insertMutant(at: mutationPoints[i], within: sourceCode)
            }

            try executor.executeProccess(logURL: logURL)

            let iterationDuration = iterationStartTime.distance(to: Date())

            let executionResult = resultParser.recognizeResult(fileURL: logURL, paths: mutatingPaths)
            mutationResults.append(executionResult.result)

            for (key, value) in context.mutants where i == (value.1.count - 1) {
                mutatingPaths.removeAll { $0 == key }
                fileManager.restoreFileFromBackup(path: key)
            }

            Logger.logEvent(.mutationIterationFinished(
                duration: iterationDuration,
                result: executionResult.result,
                killed: executionResult.killed,
                survived: executionResult.survived
            ))

            survivedCount += executionResult.survived
            killedCount += executionResult.killed
        }

        return MutationTestingResult(
            total: context.totalCount,
            survived: survivedCount,
            killed: killedCount
        )
    }
}

private extension MutationTestingStep {

    func insertMutant(at mutationPoint: MutationPoint, within sourceCode: SourceFileSyntax) {
        let mutatedSource = mutationPoint.mutationOperator(sourceCode).mutatedSource
        var path = mutationPoint.filePath
        path.removeFirst(7)
        try! mutatedSource.description.write(toFile: path, atomically: true, encoding: .utf8)
    }
}
