//
//  Created by Iurii Sorokin on 13.11.2021.
//

import Foundation

struct ReportMutation: Encodable {

    enum Result: String, Encodable {
        case killed
        case survived
    }

    let file: String?
    let line: Int
    let column: Int
    let `operator`: MutationOperator
    var result: Result?
}
