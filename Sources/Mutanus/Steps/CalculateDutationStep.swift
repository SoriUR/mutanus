//
//  Created by Iurii Sorokin on 13.11.2021.
//

import Foundation

final class CalculateDutationStep<C>: MutanusSequanceStep {

    let startTime: Date
    let reportCompiler: ReportCompiler

    init(
        startTime: Date,
        reportCompiler: ReportCompiler,
        delegate: MutanusSequanceStepDelegate?
    ) {
        self.reportCompiler = reportCompiler
        self.startTime = startTime
        self.delegate = delegate
    }

    // MARK: - MutanusSequanceStep

    typealias Context = C
    typealias Result = Void

    var delegate: MutanusSequanceStepDelegate?
    var next: AnyPerformsAction<Result>?

    func executeStep(_ context: Context) throws -> Result {
        reportCompiler.executionFinished(startTime.distance(to: Date()))
    }
}
