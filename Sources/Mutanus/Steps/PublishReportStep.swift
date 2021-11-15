//
//  Created by Iurii Sorokin on 03.11.2021.
//

import SwiftSyntax
import Foundation

final class PublishReportStep: MutanusSequanceStep {

    let reportCompiler: ReportCompiler
    let fileManager: MutanusFileManger

    init(
        reportCompiler: ReportCompiler,
        fileManager: MutanusFileManger,
        delegate: MutanusSequanceStepDelegate?
    ) {
        self.fileManager = fileManager
        self.reportCompiler = reportCompiler
        self.delegate = delegate
    }

    // MARK: - MutanusSequanceStep

    typealias Context = Void
    typealias Result = Void

    var delegate: MutanusSequanceStepDelegate?
    var next: AnyPerformsAction<Result>?

    func executeStep(_ context: Context) throws -> Result {
        let report = reportCompiler.compile()

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        let data = try encoder.encode(report)

        fileManager.createReportFile(contents: data)
    }
}
