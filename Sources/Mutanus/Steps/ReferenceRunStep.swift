//
//  Created by Iurii Sorokin on 03.11.2021.
//

import Foundation

final class ReferenceRunStep: MutanusSequenceStep {
    let executor: Executor
    let resultParser: ExecutionResultParser
    let fileManager: MutanusFileManger

    init(
        executor: Executor,
        fileManager: MutanusFileManger,
        resultParser: ExecutionResultParser,
        delegate: MutanusSequenceStepDelegate?
    ) {
        self.fileManager = fileManager
        self.executor = executor
        self.resultParser = resultParser
        self.delegate = delegate
    }

    // MARK: - MutanusSequenceStep

    typealias Context = Void
    typealias Result = ExecutionResult

    var next: AnyPerformsAction<Result>?
    weak var delegate: MutanusSequenceStepDelegate?

    func executeStep(_ context: Context) throws -> Result {

        let logFileURL = fileManager.createLogFile(name: "ReferenceRun.txt")

        try executor.executeProccess(logURL: logFileURL)
        let executionResult = resultParser.recognizeResult(in: logFileURL)

        return executionResult
    }
}
