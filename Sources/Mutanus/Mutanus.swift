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

final class Mutanus {

    let parameters: MutationParameters
    let executor: Executor
    let fileManager: MutanusFileManger

    var stepStartDate: Date!

    init(
        parameters: MutationParameters,
        executor: Executor,
        fileManager: MutanusFileManger
    ) {
        self.parameters = parameters
        self.executor = executor
        self.fileManager = fileManager
    }

    func start() throws {
        fileManager.changeCurrentDirectoryPath(parameters.directory)

        let sequence = StepsSequence()

        sequence
            .next(ReferenceRunStep(
                parameters: parameters,
                executor: executor,
                resultParser: ExecutionResultParser(),
                delegate: self
            ))
            .next(ExtractSourceFilesStep(
                fileManager: fileManager,
                parameters: parameters,
                delegate: self
            ))
            .next(FindMutantsStep(delegate: self))
            .next(MutationTestingStep(
                parameters: parameters,
                executor: executor,
                resultParser: ExecutionResultParser(),
                delegate: self
            ))

        try sequence.start()
    }
}

// MARK: - MutanusSequanceStepDelegate
extension Mutanus: MutanusSequanceStepDelegate {

    func stepFinished<T: ChainLink>(_ step: T, result: T.Result) throws {

        switch step {
        case is ReferenceRunStep:
            try handleReferenceStepResult(result as! ReferenceRunStep.Result)

        case is ExtractSourceFilesStep:
            try handleSourcesStepResult(result as! ExtractSourceFilesStep.Result)

        default:
            break
        }

        let stepDuration = stepStartDate.distance(to: Date())
        Logger.logStepDuration(stepDuration)
    }

    func stepStarted<T: ChainLink>(_ step: T) {
        stepStartDate = Date()

        switch step {
        case is ReferenceRunStep:
            Logger.logEvent(.referenceRunStart)

        case is ExtractSourceFilesStep:
            Logger.logEvent(.sourceFilesStart)

        default:
            break
        }
    }
}

// MARK: - Private
private extension Mutanus {
    func handleReferenceStepResult(_ result: ReferenceRunStep.Result) throws {
        Logger.logEvent(.referenceRunFinished(result: result))

        guard result == .testSucceeded else {
            throw MutanusError.moduleTestFailed
        }
    }

    func handleSourcesStepResult(_ result: ExtractSourceFilesStep.Result) throws {
        Logger.logEvent(.sourceFilesFinished(sources: result))

        guard !result.isEmpty else { throw MutanusError.emptySources }
    }
}
