import Foundation
import ArgumentParser

final class Entry: ParsableCommand {

    private var fileManager: MutanusFileManger { CustomFileManager() }
    private var configuration: InputConfiguration?

    @Option(name: .shortAndLong, help: "Relative or absolute path to the configuration file")
    var configurationPath: String

    func run() throws {

        guard let configuration = configuration else {
            fatalError("Neither configuration or executable has beed found")
        }

        let mutanusConfiguration = MutanusConfiguration(
            executable: configuration.executable,
            arguments: configuration.arguments,
            projectRoot: configuration.projectRoot ?? fileManager.currentDirectoryPath,
            sourceFiles: configuration.sourceFiles ?? ["/"],
            excludedFiles: configuration.excludedFiles ?? []
        )

        Logger.logEvent(.receivedConfiguration(mutanusConfiguration))

        try Mutanus(
            configuration: mutanusConfiguration,
            executor: Executor(configuration: mutanusConfiguration),
            fileManager: fileManager,
            reportCompiler: ReportCompiler(configuration: mutanusConfiguration)
        ).start()
    }
}

// MARK: - Validation
extension Entry {
    func validate() throws {

        let anyConfigurationPath: String

        let (exists, isDirectory) = fileManager.fileExists(atPath: configurationPath)

        if exists, !isDirectory {
            anyConfigurationPath = configurationPath
        } else {
            let relativeConfigurationPath = fileManager.currentDirectoryPath + "/\(configurationPath)"
            let (exists, isDirectory) = fileManager.fileExists(atPath: relativeConfigurationPath)

            if exists, !isDirectory {
                anyConfigurationPath = relativeConfigurationPath
            } else {
                throw ValidationError("Configuration file at given path doesn't exits")
            }
        }

        guard
            let data = fileManager.contents(atPath: anyConfigurationPath)
        else {
            throw ValidationError("Invalid configuration file data")
        }

        let configuration = try JSONDecoder().decode(InputConfiguration.self, from: data)

        try validateExecutable(configuration.executable)
        try validateDirectory(configuration.projectRoot)

        self.configuration = configuration
    }

    // MARK: - Private

    private func validateExecutable(_ path: String) throws {
        guard FileManager.default.isExecutableFile(atPath: path) else {
            throw ValidationError("Executable doesn't exist")
        }
    }

    private func validateDirectory(_ path: String?) throws {

        guard let path = path else { return }

        let (exists, isDirectory) = fileManager.fileExists(atPath: path)
        guard exists else {
            throw ValidationError("Path doesn't exist")
        }

        guard isDirectory else {
            throw ValidationError("Path is not a folder")
        }
    }
}

Entry.main()
