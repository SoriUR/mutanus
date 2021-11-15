//
//  Created by Iurii Sorokin on 13.11.2021.
//

import Foundation

struct IterationsReport: Encodable {

    struct Iteration: Encodable {
        let number: Int

        let startedAt: Date
        let duration: TimeInterval

        let mutants_found: Int
        let mutants_killed: Int
        let mutation_score: Float

        let mutants: [ReportMutation]
    }

    let count: Int
    var max_duration: TimeInterval?
    var average_duration: TimeInterval?

    var iterations: [Iteration]
}
