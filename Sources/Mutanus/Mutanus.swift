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

        let referenceRunStep = ReferenceRunStep(
            parameters: parameters,
            executor: executor,
            resultParser: ExecutionResultParser()
        )
        referenceRunStep.delegate = self

        let sourceFilesStep = ExtractSourceFilesStep(
            fileManager: fileManager,
            parameters: parameters
        )
        sourceFilesStep.delegate = self

        let mutantsStep = FindMutantsStep()
        mutantsStep.delegate = self

        let mutationtestingStep = MutationTestingStep(
            parameters: parameters,
            executor: executor,
            resultParser: ExecutionResultParser()
        )
        mutationtestingStep.delegate = self

        sequence
            .next(referenceRunStep)
            .next(sourceFilesStep)
            .next(mutantsStep)
            .next(mutationtestingStep)

        try sequence.start()
    }
}

extension Mutanus: MutanusSequanceStepDelegate {

    enum StepType: Int {
        case referenceRun
        case sourceFiles
        case findMutatants
        case mutationTesting
    }

    func stepFinished<T: ChainLink>(_ step: T, result: T.Result) throws {

        switch step {
        case is ReferenceRunStep:
            try handleReferenceStepResult(result as! ReferenceRunStep.Result)

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
}
