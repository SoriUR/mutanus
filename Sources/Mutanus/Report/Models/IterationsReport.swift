//
//  Created by Iurii Sorokin on 13.11.2021.
//

import Foundation

struct IterationsReport: Encodable {

    struct Iteration: Encodable {
        let timing: ReportTiming
        let score: ReportScore
        let mutations: [ReportMutation]
    }

    let count: Int
    let max_duration: TimeInterval
    let average_duration: TimeInterval

    let items: [Iteration]
}
