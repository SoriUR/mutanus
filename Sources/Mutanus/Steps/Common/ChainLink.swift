//
//  Created by Iurii Sorokin on 03.11.2021.
//

protocol ChainLink: PerformsAction, AnyObject {
    associatedtype Result

    var next: AnyPerformsAction<Result>? { get set }
}

extension ChainLink {
    @discardableResult
    func next<T: ChainLink>(_ s: T) -> T where T.Context == Result {
        next = .init(s)
        return s
    }
}

extension ChainLink where Context == Void {
    func perform() throws {
        try perform(())
    }
}
