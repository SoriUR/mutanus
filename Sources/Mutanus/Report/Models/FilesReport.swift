//
//  Created by Iurii Sorokin on 13.11.2021.
//

import Foundation

struct FilesReport: Encodable {
    let path: String

    let score: ReportScore
    let mutations: [ReportMutation]
}
