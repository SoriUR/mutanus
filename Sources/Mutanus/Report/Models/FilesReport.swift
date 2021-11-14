//
//  Created by Iurii Sorokin on 13.11.2021.
//

import Foundation

struct FilesReport: Encodable {

    struct File: Encodable {
        let path: String
        var score: ReportScore?
        var mutations: [ReportMutation]
    }

    let count: Int
    let max_mutants: Int
    let average_mutants: Int
    var items: [File]
}
