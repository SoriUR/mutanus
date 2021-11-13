//
//  Created by Iurii Sorokin on 13.11.2021.
//

import Foundation

struct GeneralReport: Encodable {
    struct File: Encodable {
        let count: Int
        let max_mutants: Int
        let average_mutants: Int
    }

    struct Iteration: Encodable {
        let count: Int
        let max_duration: TimeInterval
        let average_duration: TimeInterval
    }

    let projectRoot: String
    let executable: String
    let arguments: String

    var timing: ReportTiming?
    var score: ReportScore?
    var files: File?
    var iterations: Iteration?
}
