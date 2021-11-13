//
//  Created by Iurii Sorokin on 13.11.2021.
//

import Foundation

struct Report: Encodable {

    let projectRoot: String
    let executable: String
    let arguments: String

    var timing: ReportTiming?
    var score: ReportScore?

    var files: FilesReport?
    var iterations: IterationsReport?
}
