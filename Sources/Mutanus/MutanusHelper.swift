//
//  Created by Iurii Sorokin on 02.11.2021.
//

import Foundation

final class MutanusHelper {

    let configuration: MutanusConfiguration
    let executor: Executor
    let fileManager: MutanusFileManger
    let reportCompiler: ReportCompiler

    private var stepStartDate: Date!
    private var totalStartTime: Date!

    init(
        configuration: MutanusConfiguration,
        executor: Executor,
        fileManager: MutanusFileManger,
        reportCompiler: ReportCompiler
    ) {
        self.configuration = configuration
        self.executor = executor
        self.fileManager = fileManager
        self.reportCompiler = reportCompiler
    }

    func start() throws {
        
        fileManager.changeCurrentDirectoryPath(configuration.projectRoot)
        fileManager.createMutanusDirectories()

        let sequence = StepsSequence()

        totalStartTime = Date()
        reportCompiler.executionStarted(at: totalStartTime)

        sequence
            .next(ReferenceRunStep(
                executor: executor,
                fileManager: fileManager,
                resultParser: ExecutionResultParser(),
                delegate: self
            ))
            .next(ExtractSourceFilesStep(
                fileManager: fileManager,
                configuration: configuration,
                delegate: self
            ))
            .next(FindMutantsStep(
                reportCompiler: reportCompiler,
                delegate: self
            ))
            .next(BackupFilesStep(
                fileManager: fileManager,
                delegate: self
            ))
            .next(MutationTestingStep(
                executor: executor,
                resultParser: MutationResultParser(),
                fileManager: fileManager,
                reportCompiler: reportCompiler,
                delegate: self
            ))
            .next(CalculateDutationStep<MutationTestingStep.Result>(
                startTime: totalStartTime,
                reportCompiler: reportCompiler,
                delegate: self
            ))
            .next(PublishReportStep(
                reportCompiler: reportCompiler,
                fileManager: fileManager,
                delegate: self
            ))

        try sequence.start()
    }
}

// MARK: - MutanusSequanceStepDelegate
extension MutanusHelper: MutanusSequanceStepDelegate {

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

// MARK: - MutationTestingStepDelegate
extension MutanusHelper: MutationTestingStepDelegate {
    func iterationStated(index: Int) {
        Logger.logEvent(.mutationIterationStarted(index: index+1))
    }

    func iterationFinished(duration: TimeInterval, result: ExecutionReport) {
        Logger.logEvent(.mutationIterationFinished(
            duration: duration,
            result: result
        ))
    }
}

// MARK: - Private
private extension MutanusHelper {
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
        Logger.logEvent(.mutationTestingFinished(total: result.total, killed: result.killed))
    }
}
