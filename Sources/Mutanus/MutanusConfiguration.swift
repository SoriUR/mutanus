//
//  Created by Iurii Sorokin on 06.12.2021.
//

import Foundation

struct InputConfiguration: Decodable {
    let executable: String
    let arguments: [String]
    let projectRoot: String?
    let sourceFiles: [String]?
    let excludedFiles: [String]?

    enum CodingKeys: String, CodingKey {
        case executable
        case arguments
        case projectRoot = "project_root"
        case sourceFiles = "source_files"
        case excludedFiles = "excluded_files"
    }
}

struct MutanusConfiguration {
    let executable: String
    let arguments: [String]
    let projectRoot: String
    let sourceFiles: [String]
    let excludedFiles: [String]
}
