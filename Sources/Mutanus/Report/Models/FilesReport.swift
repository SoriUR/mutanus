//
//  Created by Iurii Sorokin on 13.11.2021.
//

import Foundation

struct FilesReport: Encodable {

    final class File: Encodable {
        let path: String

        var mutants_found: Int = 0
        var mutants_killed: Int = 0
        var mutation_score: Float = 0

        var mutants: [ReportMutation] = []

        init(path: String) {
            self.path = path
        }
    }

    let count: Int
    let max_mutants: Int
    let average_mutants: Int
    var files: [File]
}
