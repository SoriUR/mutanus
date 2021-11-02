//
//  Created by Iurii Sorokin on 02.11.2021.
//

import Foundation

struct MutationParameters {
    let directory: String
    let executable: String
    let arguments: [String]
    let files: [String]
}

struct Mutanus {

    let parameters: MutationParameters
    let executor: Executor

    init(
        parameters: MutationParameters,
        executor: Executor
    ) {
        self.parameters = parameters
        self.executor = executor
    }

    func start() throws {

        Logger.logEvent(.referenceRunStart)

        let info = try executor.executeProccess(with: parameters)
        let executionResult = ExecutionResultParser.recognizeResult(in: info.logURL)

        Logger.logEvent(.referenceRunFinished(duration: info.duration, result: executionResult))

        guard executionResult == .testSucceeded else {
            fatalError("Module tests failed")
        }

        let mutantsMaxCount = Int.random(in: 2...5)

        var mutationResults = [ExecutionResult]()
        mutationResults.reserveCapacity(mutantsMaxCount)

        Logger.logEvent(.mutationTestingStarted(count: mutantsMaxCount))

        let startTime = Date()

        for i in 0..<mutantsMaxCount {
            Logger.logEvent(.mutationIterationStarted(index: i))

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

