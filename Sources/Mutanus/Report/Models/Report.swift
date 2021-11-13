//
//  Created by Iurii Sorokin on 13.11.2021.
//

import Foundation

struct Report: Encodable {
    var general: GeneralReport
    var files: [FilesReport]
    var iterations: [IterationsReport]
}
