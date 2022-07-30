//  Created by Юра Сорокин on 30.07.2022.

import Foundation
import ArgumentParser

protocol ConfigValidator {
    var fileManager: MutanusFileManger { get }

    func validateConfig(atPath path: String) throws -> MutanusConfiguration
    func validateConfig(_ config: InputConfiguration) throws -> MutanusConfiguration
}

extension ConfigValidator {

    func validateConfig(atPath path: String) throws -> MutanusConfiguration {
        guard let data = fileManager.contents(atPath: path) else {
            throw ValidationError("Invalid configuration file data")
        }

        let inputConfiguration = try JSONDecoder().decode(InputConfiguration.self, from: data)

        return try validateConfig(inputConfiguration)
    }

    func validateConfig(_ config: InputConfiguration) throws -> MutanusConfiguration {
        try validateExecutable(config.executable)
        try validateDirectory(config.projectRoot)

        return MutanusConfiguration(
            executable: config.executable,
            arguments: config.arguments,
            projectRoot: config.projectRoot ?? fileManager.currentDirectoryPath,
            includedFiles: config.includedFiles ?? [],
            includedRules: config.includedRules ?? [],
            excludedFiles: config.excludedFiles ?? [],
            excludedRules: config.excludedRules ?? [],
            options: config.options ?? []
        )
    }
}

// MARK: - Private
private extension ConfigValidator {

    private func validateExecutable(_ path: String) throws {
        guard fileManager.isExecutableFile(atPath: path) else {
            throw ValidationError("Executable doesn't exist")
        }
    }

    private func validateDirectory(_ path: String?) throws {

        guard let path = path else { return }

        let (exists, isDirectory) = fileManager.fileExists(atPath: path)
        guard exists else {
            throw ValidationError("Project root path doesn't exist")
        }

        guard isDirectory else {
            throw ValidationError("Project root path is not a folder")
        }
    }
}
