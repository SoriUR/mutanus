//
//  Created by Iurii Sorokin on 03.11.2021.
//

protocol MutanusSequanceStep: ChainLink {
    func performStep(_ context: Context) throws -> Result
}

extension MutanusSequanceStep {
    func perform(_ context: Context) throws {
        let result = try  performStep(context)
        try next?.perform(result)
    }
}

