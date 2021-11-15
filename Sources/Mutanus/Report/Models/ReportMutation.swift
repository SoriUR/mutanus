//
//  Created by Iurii Sorokin on 13.11.2021.
//

import Foundation

struct ReportMutation: Encodable {

    let file: String?
    let line: Int
    let column: Int
    let `operator`: MutationOperator
    let result: MutationResult
}

enum MutationResult: String, Encodable {
    case killed
    case survived
}
