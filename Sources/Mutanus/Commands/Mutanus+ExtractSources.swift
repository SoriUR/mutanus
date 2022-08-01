//
//  Created by Iurii Sorokin on 08.03.2022.
//

import Foundation
import ArgumentParser

extension Mutanus {
    final class ExtractSources: ParsableCommand, PathValidator, ConfigValidator {

        static let configuration = CommandConfiguration(abstract: "Extracts sources for given configuration")
        var fileManager: MutanusFileManger { CustomFileManager() }

        @Option(name: .shortAndLong, help: "Relative or absolute path to the configuration file")
        var configPath: String

        func run() throws {

            let configuration = try validateConfig(atPath: configPath)

            Logger.logEvent(.receivedConfiguration(configuration))

            _ = try ExtractSourceFilesStep(
                fileManager: fileManager,
                configuration: configuration,
                delegate: nil
            ).executeStep(.testSucceeded)
        }
    }
}

// MARK: - Validation
extension Mutanus.ExtractSources {
    func validate() throws {
        configPath = try validatePath(configPath)
    }
}
