//
//  Created by Iurii Sorokin on 08.03.2022.
//

import Foundation
import ArgumentParser

extension Mutanus {
    final class FindMutants: ParsableCommand, PathValidator, ConfigValidator {

        static let configuration = CommandConfiguration(abstract: "Find mutants for given configuration or file")
        var fileManager: MutanusFileManger { CustomFileManager() }

        @Option(name: .shortAndLong, help: "Relative or absolute path to the configuration file")
        var configPath: String?

        @Option(name: .shortAndLong, parsing: .upToNextOption, help: "Relative or absolute paths to files")
        var files: [String] = []

        func run() throws {

            let filesTest: [String]

            if let configPath = configPath {
                let configuration = try validateConfig(atPath: configPath)
                
                filesTest = try ExtractSourceFilesStep(
                    fileManager: fileManager,
                    configuration: configuration,
                    delegate: self
                ).executeStep(.testSucceeded)
            } else {
                filesTest = files
            }

            print(try FindMutantsStep().executeStep(filesTest))
        }
    }
}

// MARK: - Validation
extension Mutanus.FindMutants {
    func validate() throws {

        guard configPath != nil || !files.isEmpty else { throw ValidationError("asd") }

        if let configPath = configPath {
            self.configPath = try validatePath(configPath)
        }

        files = try files.map { try validatePath($0) }
    }
}
