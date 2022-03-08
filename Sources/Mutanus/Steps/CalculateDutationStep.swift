//
//  Created by Iurii Sorokin on 13.11.2021.
//

import Foundation

final class CalculateDutationStep<C>: MutanusSequenceStep {

    let startTime: Date
    let reportCompiler: ReportCompiler

    init(
        startTime: Date,
        reportCompiler: ReportCompiler,
        delegate: MutanusSequenceStepDelegate?
    ) {
        self.reportCompiler = reportCompiler
        self.startTime = startTime
        self.delegate = delegate
    }

    // MARK: - MutanusSequenceStep

    typealias Context = C
    typealias Result = Void

    var delegate: MutanusSequenceStepDelegate?
    var next: AnyPerformsAction<Result>?

    func executeStep(_ context: Context) throws -> Result {
        reportCompiler.executionFinished(startTime.distance(to: Date()))
    }
}
