//
//  Created by Iurii Sorokin on 03.11.2021.
//

final class StepsSequence: ChainLink {
    typealias Result = Void
    typealias Context = Void

    var next: AnyPerformsAction<Void>?

    func perform(_ context: Void) throws {
        try next?.perform(context)
    }

    func start() throws {
        try perform(())
    }
}
