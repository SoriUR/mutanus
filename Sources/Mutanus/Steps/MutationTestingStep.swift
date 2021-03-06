//
//  Created by Iurii Sorokin on 03.11.2021.
//

import SwiftSyntax
import Foundation

struct MutationTestingResult {
    let total: Int
    let killed: Int
}

struct MutationTestingIterationReport {

    struct Mutation {
        let path: String
        let point: MutationPoint
        let result: MutationResult
    }

    let number: Int
    let started: Date
    let duration: TimeInterval
    let mutations: [Mutation]
    let report: ExecutionReport
}


protocol MutationTestingStepDelegate: MutanusSequenceStepDelegate {
    func iterationStated(index: Int)
    func iterationFinished(duration: TimeInterval, result: ExecutionReport)
}

final class MutationTestingStep: MutanusSequenceStep {

    let executor: Executor
    let resultParser: MutationResultParser
    let fileManager: MutanusFileManger
    let reportCompiler: ReportCompiler

    weak var stepDelegate: MutationTestingStepDelegate?

    init(
        executor: Executor,
        resultParser: MutationResultParser,
        fileManager: MutanusFileManger,
        reportCompiler: ReportCompiler,
        delegate: MutationTestingStepDelegate?
    ) {
        self.fileManager = fileManager
        self.executor = executor
        self.resultParser = resultParser
        self.stepDelegate = delegate
        self.reportCompiler = reportCompiler
    }

    // MARK: - MutanusSequenceStep

    typealias Context = MutantsInfo
    typealias Result = MutationTestingResult

    var delegate: MutanusSequenceStepDelegate? { stepDelegate }
    var next: AnyPerformsAction<Result>?

    func executeStep(_ context: Context) throws -> Result {

        var iterationResults: [MutationTestingIterationReport] = []
        iterationResults.reserveCapacity(context.maxFileCount)

        var killedCount = 0

        // Пути к файлам, в которых остались мутанты
        var mutatingFilePaths: [String] = context.mutants.keys.map { $0 }

        // Делаем столько итераций, сколько макс мутантов в 1м файле
        for i in 0..<context.maxFileCount {

            let iterationStartTime = Date()
            stepDelegate?.iterationStated(index: i)
            let logURL = fileManager.createLogFile(name: "Iteration\(i+1).txt")

            // Мутации в данной итерации
            var mutations: [(path: String, point: MutationPoint)] = []

            // Идем по всем файлам с мутантами
            for (path, mutantInfo) in context.mutants {
                let mutationPoints = mutantInfo.points

                // проверяем что мутантов больше, чем текущая итерация
                guard i < mutationPoints.count else { continue }

                // мутируем файл
                insertMutant(to: path, mutationPoint: mutationPoints[i], within: mutantInfo.source)
                mutations.append((path, mutationPoints[i]))
            }

            // запускаем сборку
            try executor.executeProccess(logURL: logURL)

            let iterationDuration = iterationStartTime.distance(to: Date())
            let executionResult = resultParser.recognizeResult(fileURL: logURL, paths: mutatingFilePaths)

            // файлы в которых больше нет мутантов, откатываем до исходных
            for (key, value) in context.mutants where i == (value.points.count - 1) {
                mutatingFilePaths.removeAll { $0 == key }
                fileManager.restoreFileFromBackup(path: key)
            }

            let iterationResult = MutationTestingIterationReport(
                number: i,
                started: iterationStartTime,
                duration: iterationDuration,
                mutations: mutations.map {
                    .init(
                        path: $0.path,
                        point: $0.point,
                        result: executionResult.killed.contains($0.path) ? .killed : .survived
                    )},
                report: executionResult
            )

            iterationResults.append(iterationResult)
            killedCount += executionResult.killed.count
            stepDelegate?.iterationFinished(duration: iterationDuration, result: executionResult)
        }

        reportCompiler.iterationsFinished(iterationResults)

        return MutationTestingResult(
            total: context.totalCount,
            killed: killedCount
        )
    }
}

private extension MutationTestingStep {

    func insertMutant(to path: String, mutationPoint: MutationPoint, within sourceCode: SourceFileSyntax) {

        let rewriter = mutationPoint.operator.rewriter(mutationPoint.position)
        let mutatedSource = rewriter.visit(sourceCode)

        try! mutatedSource.description.write(toFile: path, atomically: true, encoding: .utf8)
    }
}
