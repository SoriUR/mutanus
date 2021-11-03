//
//  MutationTestingStep.swift
//  Mutanus
//
//  Created by Iurii Sorokin on 03.11.2021.
//

import Foundation

final class MutationTestingStep: MutanusSequanceStep {
    typealias Context = [String: [MutationPoint]]
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
            return result > current.count ? result : current.count
        }

        var mutationResults = [ExecutionResult]()
        mutationResults.reserveCapacity(mutantsMaxCount)

        Logger.logEvent(.mutationTestingStarted(count: mutantsMaxCount))

        let startTime = Date()

        for i in 0..<mutantsMaxCount {
            Logger.logEvent(.mutationIterationStarted(index: i+1))



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
}
