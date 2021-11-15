//
//  Created by Iurii Sorokin on 13.11.2021.
//

import Foundation

struct Report: Encodable {

    let projectRoot: String
    let executable: String
    let arguments: String

    var startedAt: Date? = nil
    var duration: TimeInterval = 0

    var mutants_found: Int = 0
    var mutants_killed: Int = 0
    var mutation_score: Float = 0

    var files: FilesReport? = nil
    var iterations: IterationsReport? = nil
}
