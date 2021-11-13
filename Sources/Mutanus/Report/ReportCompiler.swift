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
        report.timing = .init(startedAt: date, duration: 0)
    }

    func executionDuration(_ duration: TimeInterval) {
        report.timing?.duration = duration
    }

    func compile() -> Report {
        return report
    }
}
