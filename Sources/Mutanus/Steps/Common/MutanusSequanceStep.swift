//
//  Created by Iurii Sorokin on 03.11.2021.
//

protocol MutanusSequanceStepDelegate: AnyObject {
    func stepStarted<T: ChainLink>(_ step: T)
    func stepFinished<T: ChainLink>(_ step: T, result: T.Result) throws
}

protocol MutanusSequanceStep: ChainLink {
    var delegate: MutanusSequanceStepDelegate? { get }

    func executeStep(_ context: Context) throws -> Result
}

extension MutanusSequanceStep {
    func perform(_ context: Context) throws {
        delegate?.stepStarted(self)
        let result = try executeStep(context)
        try delegate?.stepFinished(self, result: result)
        try next?.perform(result)
    }
}

