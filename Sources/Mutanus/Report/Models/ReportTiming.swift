//
//  Created by Iurii Sorokin on 13.11.2021.
//

import Foundation

struct ReportTiming: Encodable {
    let startedAt: Date
    var duration: TimeInterval?
}
