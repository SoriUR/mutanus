//
//  ReferenceRunStep.swift
//  ArgumentParser
//
//  Created by Iurii Sorokin on 03.11.2021.
//

import Foundation

final class ReferenceRunStep: MutanusSequanceStep {
    typealias Context = Void
    typealias Result = ExecutionResult

    let parameters: MutationParameters
    let executor: Executor
    let resultParser: ExecutionResultParser

    init(
        parameters: MutationParameters,
        executor: Executor,
        resultParser: ExecutionResultParser
    ) {
        self.parameters = parameters
        self.executor = executor
        self.resultParser = resultParser
    }

    // MARK: - MutanusSequanceStep

    var next: AnyPerformsAction<Result>?
    var delegate: MutanusSequanceStepDelegate?

    func executeStep(_ context: Context) throws -> Result {
        let info = try executor.executeProccess(with: parameters)
        let executionResult = resultParser.recognizeResult(in: info.logURL)

        return executionResult
    }
}
