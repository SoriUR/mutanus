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
            average_mutants: Int((Float(info.totalCount)/Float(info.mutants.count)).rounded()),
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
    }

    func compile() -> Report {
        return report
    }
}
