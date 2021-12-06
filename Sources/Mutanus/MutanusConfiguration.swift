//
//  Created by Iurii Sorokin on 06.12.2021.
//

import Foundation

struct InputConfiguration: Decodable {
    let executable: String
    let arguments: [String]
    let projectPath: String?
    let sourcePaths: [String]?

    enum CodingKeys: String, CodingKey {
        case executable
        case arguments
        case projectPath = "project_path"
        case sourcePaths = "source_paths"
    }
}

struct MutanusConfiguration {
    let executable: String
    let arguments: [String]
    let projectPath: String
    let sourcePaths: [String]
}
