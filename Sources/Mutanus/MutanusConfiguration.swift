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
    let includedFiles: [String]?
    let includedRules: [String]?
    let excludedFiles: [String]?
    let excludedRules: [String]?
    let options: [ConfigurationOption]?

    enum CodingKeys: String, CodingKey {
        case executable
        case arguments
        case projectRoot = "project_root"
        case includedFiles = "included_files"
        case includedRules = "included_rules"
        case excludedFiles = "excluded_files"
        case excludedRules = "excluded_rules"
        case options = "options"
    }
}

struct MutanusConfiguration {
    let executable: String
    let arguments: [String]
    let projectRoot: String
    let includedFiles: [String]
    let includedRules: [String]
    let excludedFiles: [String]
    let excludedRules: [String]
    let options: [ConfigurationOption]
}
