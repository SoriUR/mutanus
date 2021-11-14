//
//  Created by Iurii Sorokin on 13.11.2021.
//

import Foundation

struct IterationsReport: Encodable {

    struct Iteration: Encodable {
        let number: Int
        var timing: ReportTiming
        var score: ReportScore?
        var mutations: [ReportMutation]?
    }

    let count: Int
    var max_duration: TimeInterval?
    var average_duration: TimeInterval?

    var items: [Iteration]
}
