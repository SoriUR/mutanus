//
//  Created by Iurii Sorokin on 13.11.2021.
//

import Foundation

struct IterationsReport: Encodable {
    let number: Int

    let timing: ReportTiming
    let score: ReportScore
    let mutations: [ReportMutation]
}
