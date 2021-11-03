//
//  ReferenceRunStep.swift
//  ArgumentParser
//
//  Created by Iurii Sorokin on 03.11.2021.
//

import Foundation

final class ReferenceRunStep: MutanusSequanceStep {
    typealias Context = Void
    typealias Result = Void

    let parameters: MutationParameters
    let executor: Executor

    init(
        parameters: MutationParameters,
        executor: Executor
    ) {
        self.parameters = parameters
        self.executor = executor
    }

    var next: AnyPerformsAction<Result>?

    func performStep(_ context: Context) throws -> Result {
        Logger.logEvent(.referenceRunStart)

        let info = try executor.executeProccess(with: parameters)
        let executionResult = ExecutionResultParser.recognizeResult(in: info.logURL)

        Logger.logEvent(.referenceRunFinished(duration: info.duration, result: executionResult))

        guard executionResult == .testSucceeded else {
            fatalError("Module tests failed")
        }
    }
}
