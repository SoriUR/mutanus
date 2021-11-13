//
//  Created by Iurii Sorokin on 13.11.2021.
//

import Foundation

struct FilesReport: Encodable {

    struct File: Encodable {
        let path: String
        let score: ReportScore
        let mutations: [ReportMutation]
    }

    let count: Int
    let max_mutants: Int
    let average_mutants: Int
    let items: [File]
}
