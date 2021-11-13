//
//  Created by Iurii Sorokin on 13.11.2021.
//

struct ReportScore: Encodable {
    let found: Int
    let killed: Int
    let survived: Int
    let score: Float
}
