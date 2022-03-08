//
//  Created by Iurii Sorokin on 03.11.2021.
//

protocol MutanusSequenceStepDelegate: AnyObject {
    func stepStarted<T: ChainLink>(_ step: T)
    func stepFinished<T: ChainLink>(_ step: T, result: T.Result) throws
}

protocol MutanusSequenceStep: ChainLink {
    var delegate: MutanusSequenceStepDelegate? { get }

    func executeStep(_ context: Context) throws -> Result
}

extension MutanusSequenceStep {
    func perform(_ context: Context) throws {
        delegate?.stepStarted(self)
        let result = try executeStep(context)
        try delegate?.stepFinished(self, result: result)
        try next?.perform(result)
    }
}

