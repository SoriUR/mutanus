//
//  Created by Iurii Sorokin on 13.11.2021.
//

import Foundation

final class ReportCompiler {

    private var report: Report

    init(parameters: MutationParameters) {

        self.report = .init(
            projectRoot: parameters.directory,
            executable: parameters.executable,
            arguments: parameters.arguments.joined(separator: " "),
            timing: nil,
            score: nil,
            files: nil,
            iterations: nil
        )
    }

    func executionStarted(at date: Date) {
        report.timing = .init(startedAt: date, duration: nil)
    }

    func executionDuration(_ duration: TimeInterval) {
        report.timing?.duration = duration
    }

    func extractedSources(_ info: MutantsInfo) {
        report.files = .init(
            count: info.mutants.count,
            max_mutants: info.maxFileCount,
            average_mutants: info.totalCount / info.mutants.count,
            items: info.mutants.map { mutations in
                .init(
                    path: mutations.key,
                    score: nil,
                    mutations: mutations.value.points.map {
                        .init(
                            file: nil,
                            line: $0.position.line,
                            column: $0.position.column,
                            operator: $0.operator,
                            result: nil
                        )
                    }
                )
            }
        )

        report.iterations = .init(
            count: info.maxFileCount,
            max_duration: nil,
            average_duration: nil,
            items: []
        )
    }

    func iterationStarted(number: Int, timeStarted: Date) {
        report.iterations?.items.append(
            .init(
                number: number,
                timing: .init(startedAt: timeStarted, duration: nil),
                score: nil,
                mutations: nil
            )
        )
    }

    func iterationFinished(_ result: MutationTestingIterationResult) {
        guard
            let index = report.iterations?.items.firstIndex(where: { $0.number == result.number }),
            var iteration = report.iterations?.items[index]
        else { return }

        iteration.timing.duration = result.duration
        iteration.score = .init(
            found: result.mutations.count,
            killed: result.report.killed.count,
            survived: result.report.survived.count,
            score: result.report.killed.count / result.mutations.count * 100
        )
        iteration.mutations = result.mutations.map {
            .init(
                file: $0.path,
                line: $0.point.position.line,
                column: $0.point.position.column,
                operator: $0.point.operator,
                result: $0.result
            )
        }

        report.iterations?.items[index] = iteration
    }

    func compile() -> Report {
        return report
    }
}

private extension Int {
    static func / (_ lhs: Int, _ rhs: Int) -> Int {
        Int((Float(lhs)/Float(rhs)).rounded())
    }

    static func / (_ lhs: Int, _ rhs: Int) -> Float {
        Float(lhs)/Float(rhs)
    }
}
