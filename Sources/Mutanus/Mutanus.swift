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
        fileManager.createMutanusDirectories()

        let sequence = StepsSequence()

        let startDate = Date()

        sequence
            .next(ReferenceRunStep(
                executor: executor,
                fileManager: fileManager,
                resultParser: ExecutionResultParser(),
                delegate: self
            ))
            .next(ExtractSourceFilesStep(
                fileManager: fileManager,
                parameters: parameters,
                delegate: self
            ))
            .next(FindMutantsStep(delegate: self))
            .next(BackupFilesStep(
                fileManager: fileManager,
                delegate: self
            ))
            .next(MutationTestingStep(
                executor: executor,
                resultParser: MutationResultParser(),
                fileManager: fileManager,
                delegate: self
            ))

        try sequence.start()

        let duration = startDate.distance(to: Date())
        Logger.logTotalDuration(duration)
    }
}

// MARK: - MutanusSequanceStepDelegate
extension Mutanus: MutanusSequanceStepDelegate {

    func stepStarted<T: ChainLink>(_ step: T) {
        stepStartDate = Date()

        switch step {
        case is ReferenceRunStep:
            Logger.logEvent(.referenceRunStarted)

        case is ExtractSourceFilesStep:
            Logger.logEvent(.sourceFilesStarted)

        case is FindMutantsStep:
            Logger.logEvent(.findMutantsStarted)

        case is BackupFilesStep:
            Logger.logEvent(.filesBackupStared)

        case is MutationTestingStep:
            Logger.logEvent(.mutationTestingStarted)

        default:
            break
        }
    }

    func stepFinished<T: ChainLink>(_ step: T, result: T.Result) throws {

        switch step {
        case is ReferenceRunStep:
            try handleReferenceStepResult(result as! ReferenceRunStep.Result)

        case is ExtractSourceFilesStep:
            try handleSourcesStepResult(result as! ExtractSourceFilesStep.Result)

        case is FindMutantsStep:
            try handleFindMutantsStepResult(result as! FindMutantsStep.Result)

        case is MutationTestingStep:
            handleMutationTestingStepResult(result as! MutationTestingStep.Result)

        default:
            break
        }

        let stepDuration = stepStartDate.distance(to: Date())
        Logger.logStepDuration(stepDuration)
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

    func handleFindMutantsStepResult(_ result: FindMutantsStep.Result) throws {
        Logger.logEvent(.findMutantsFinished(result: result))

        guard result.totalCount != 0 else { throw MutanusError.zeroMutants }
    }

    func handleMutationTestingStepResult(_ result: MutationTestingStep.Result) {
        Logger.logEvent(.mutationTestingFinished(total: result.total, killed: result.killed, survived: result.survived))
    }
}
