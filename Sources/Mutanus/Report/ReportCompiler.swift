//
//  Created by Iurii Sorokin on 13.11.2021.
//

import Foundation

final class ReportCompiler {

    let parameters: MutationParameters
    var report: Report

    init(parameters: MutationParameters) {
        self.parameters = parameters
        self.report = .init(
            general: .init(
                projectRoot: parameters.directory,
                executable: parameters.executable,
                arguments: parameters.arguments.joined(separator: " "),
                timing: nil,
                score: nil,
                files: nil,
                iterations: nil
            ),
            files: [],
            iterations: []
        )
    }

    func compile() -> Report {
        return report
    }
}
