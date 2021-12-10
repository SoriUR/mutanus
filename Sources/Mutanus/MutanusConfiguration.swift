//
//  Created by Iurii Sorokin on 06.12.2021.
//

import Foundation

enum ConfigurationOption: String, Codable {
    case verificationRun = "verification_run"
}

struct InputConfiguration: Codable {
    let executable: String
    let arguments: [String]
    let projectRoot: String?
    let sourceFiles: [String]?
    let excludedFiles: [String]?
    let options: [ConfigurationOption]?

    enum CodingKeys: String, CodingKey {
        case executable
        case arguments
        case projectRoot = "project_root"
        case sourceFiles = "source_files"
        case excludedFiles = "excluded_files"
        case options = "options"
    }
}

struct MutanusConfiguration {
    let executable: String
    let arguments: [String]
    let projectRoot: String
    let sourceFiles: [String]
    let excludedFiles: [String]
    let options: [ConfigurationOption]
}
