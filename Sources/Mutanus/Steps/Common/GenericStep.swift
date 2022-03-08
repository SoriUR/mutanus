//
//  Created by Iurii Sorokin on 15.11.2021.
//

import Foundation

final class GenericStep<C, R>: MutanusSequenceStep {

    let executeBlock: (C) throws -> R

    init(
        executeBlock: @escaping (C) throws -> R,
        delegate: MutanusSequenceStepDelegate?
    ) {
        self.executeBlock = executeBlock
        self.delegate = delegate
    }

    // MARK: - MutanusSequenceStep

    typealias Context = C
    typealias Result = R

    weak var delegate: MutanusSequenceStepDelegate?
    var next: AnyPerformsAction<Result>?

    func executeStep(_ context: Context) throws -> Result {
        try executeBlock(context)
    }
}
