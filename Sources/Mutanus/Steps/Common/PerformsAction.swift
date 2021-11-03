//
//  Created by Iurii Sorokin on 03.11.2021.
//

protocol PerformsAction {
    associatedtype Context
    func perform(_ context: Context) throws
}

final class AnyPerformsAction<T>: PerformsAction {
    typealias Context = T

    var _perform: (T) throws -> ()

    init<S: PerformsAction>(_ concrete: S) where S.Context == T {
        _perform = concrete.perform
    }

    func perform(_ context: T) throws {
        try _perform(context)
    }
}
