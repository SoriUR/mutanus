//
//  Created by Iurii Sorokin on 03.11.2021.
//

import SwiftSyntax
import Foundation

final class PublishReportStep: MutanusSequenceStep {

    let reportCompiler: ReportCompiler
    let fileManager: MutanusFileManger

    init(
        reportCompiler: ReportCompiler,
        fileManager: MutanusFileManger,
        delegate: MutanusSequenceStepDelegate?
    ) {
        self.fileManager = fileManager
        self.reportCompiler = reportCompiler
        self.delegate = delegate
    }

    // MARK: - MutanusSequenceStep

    typealias Context = Void
    typealias Result = Void

    weak var delegate: MutanusSequenceStepDelegate?
    var next: AnyPerformsAction<Result>?

    func executeStep(_ context: Context) throws -> Result {
        let report = reportCompiler.compile()

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        let data = try encoder.encode(report)

        fileManager.createReportFile(contents: data)
    }
}
