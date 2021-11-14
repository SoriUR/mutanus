//
//  Created by Iurii Sorokin on 13.11.2021.
//

import Foundation

final class GenericStep<C, R>: MutanusSequanceStep {

    let executeBlock: (C) throws -> R

    init(
        executeBlock: @escaping (C) throws -> R,
        delegate: MutanusSequanceStepDelegate?
    ) {
        self.executeBlock = executeBlock
        self.delegate = delegate
    }

    // MARK: - MutanusSequanceStep

    typealias Context = C
    typealias Result = R

    var delegate: MutanusSequanceStepDelegate?
    var next: AnyPerformsAction<Result>?

    func executeStep(_ context: Context) throws -> Result {
        try executeBlock(context)
    }
}


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
    typealias Result = C

    var delegate: MutanusSequanceStepDelegate?
    var next: AnyPerformsAction<Result>?

    func executeStep(_ context: Context) throws -> Result {
        let duration = startTime.distance(to: Date())
        reportCompiler.executionDuration(duration)
        return context
    }
}
