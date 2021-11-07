//
//  Created by Iurii Sorokin on 03.11.2021.
//

import SwiftSyntax
import Foundation

final class MutationTestingStep: MutanusSequanceStep {
    typealias Context = [String: (SourceFileSyntax, [MutationPoint])]
    typealias Result = Void

    var next: AnyPerformsAction<Result>?

    let parameters: MutationParameters
    let executor: Executor

    init(
        parameters: MutationParameters,
        executor: Executor
    ) {
        self.parameters = parameters
        self.executor = executor
    }

    func performStep(_ context: Context) throws -> Result {
        let mutantsMaxCount = context.values.reduce(0) { result, current in
            return result > current.1.count ? result : current.1.count
        }

        var mutationResults = [ExecutionResult]()
        mutationResults.reserveCapacity(mutantsMaxCount)

        Logger.logEvent(.mutationTestingStarted(count: mutantsMaxCount))

        let startTime = Date()

        for i in 0..<mutantsMaxCount {
            Logger.logEvent(.mutationIterationStarted(index: i+1))

            for (_, value) in context {
                let mutationPoints = value.1

                guard i < mutationPoints.count else { continue }

                let sourceCode = value.0
                insertMutant(at: mutationPoints[i], within: sourceCode)
            }

            let info = try executor.executeProccess(with: parameters)
            let executionResult = ExecutionResultParser.recognizeResult(in: info.logURL)

            Logger.logEvent(.mutationIterationFinished(duration: info.duration, result: executionResult))

            mutationResults.append(executionResult)
        }

        let duration = startTime.distance(to: Date())

        var survivedCount = 0
        var killedCount = 0

        mutationResults.forEach { result in
            let increment = result == .testFailed ? 1 : 0
            killedCount += increment
            survivedCount += 1 - increment
        }

        Logger.logEvent(.mutationTestingFinished(duration: duration, total: mutantsMaxCount, killed: killedCount, survived: survivedCount))
    }

    private func backupFile(at path: String, using swapFilePaths: [String: String]) {
        let swapFilePath = swapFilePaths[path]!
        copySourceCode(fromFileAt: path, to: swapFilePath)
    }

    private func restoreFile(at path: String, using swapFilePaths: [String: String]) {
        let swapFilePath = swapFilePaths[path]!
        copySourceCode(fromFileAt: swapFilePath, to: path)
    }

    private func insertMutant(at mutationPoint: MutationPoint, within sourceCode: SourceFileSyntax) {
        let mutatedSource = mutationPoint.mutationOperator(sourceCode).mutatedSource
        var path = mutationPoint.filePath
        path.removeFirst(7)
        try! mutatedSource.description.write(toFile: path, atomically: true, encoding: .utf8)
    }

    private func copySourceCode(fromFileAt sourcePath: String, to destinationPath: String) {
        let source = sourceCode(fromFileAt: sourcePath)
        try? source?.code.description.write(toFile: destinationPath, atomically: true, encoding: .utf8)
    }
}
