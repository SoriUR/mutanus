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


