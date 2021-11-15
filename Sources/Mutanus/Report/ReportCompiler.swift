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
            arguments: parameters.arguments.joined(separator: " ")
        )
    }

    func executionStarted(at date: Date) {
        report.startedAt = date
    }

    func executionFinished(_ duration: TimeInterval) {
        report.duration = duration

        var found = 0
        var killed = 0

        report.iterations?.iterations.forEach {
            found += $0.mutants_found
            killed += $0.mutants_killed
        }

        report.mutants_found = found
        report.mutants_killed = killed
        report.mutation_score = killed / found * 100
    }

    func extractedSources(_ info: MutantsInfo) {
        report.files = .init(
            count: info.mutants.count,
            max_mutants: info.maxFileCount,
            average_mutants: info.totalCount / info.mutants.count,
            files: info.mutants.map { .init(path: $0.key) }
        )

        report.iterations = .init(
            count: info.maxFileCount,
            max_duration: nil,
            average_duration: nil,
            iterations: []
        )
    }

    func iterationsFinished(_ reports: [MutationTestingIterationReport]) {

        var maxDuration = TimeInterval(0)

        reports.forEach {
            iterationFinished($0)
            maxDuration = maxDuration > $0.duration ? maxDuration : $0.duration
        }

        report.iterations?.max_duration = maxDuration
        report.iterations?.average_duration = maxDuration/Double(reports.count)

        reports.forEach { report in
            report.mutations.forEach { mutation in

                guard
                    let files = self.report.files?.files,
                    let index = files.firstIndex(where: { $0.path == mutation.path})
                else { return }

                let file = files[index]
                file.mutants_found += 1
                file.mutants_killed += mutation.result == .killed ? 1 : 0
                file.mutants.append(.init(
                    file: nil,
                    point: mutation.point,
                    result: mutation.result
                ))
            }
        }

        self.report.files?.files.forEach {
            $0.mutation_score = $0.mutants_killed / $0.mutants_found * 100
        }
    }

    private func iterationFinished(_ result: MutationTestingIterationReport) {
        report.iterations?.iterations.append(
            .init(
                number: result.number,
                startedAt: result.started,
                duration: result.duration,
                mutants_found: result.mutations.count,
                mutants_killed: result.report.killed.count,
                mutation_score: result.report.killed.count / result.mutations.count * Float(100),
                mutants: result.mutations.map {
                    .init(
                        file: $0.path,
                        point: $0.point,
                        result: $0.result
                    )
                }
            )
        )
    }

    func compile() -> Report {
        return report
    }
}

private extension ReportMutation {
    init(file: String?, point: MutationPoint, result: MutationResult) {
        self.file = file
        self.line = point.position.line
        self.column = point.position.column
        self.operator = point.operator
        self.result = result
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
