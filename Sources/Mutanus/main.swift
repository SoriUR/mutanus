import Foundation
import ArgumentParser

struct Mutanus: ParsableCommand {

    static let configuration = CommandConfiguration(
        abstract: "Performs Mutation testing of a Swift project",
        subcommands: [
            Run.self,
            Config.self
        ]
    )

    struct Config: ParsableCommand {

        static let configuration = CommandConfiguration(abstract: "Creates configuration file")

        private var fileManager: MutanusFileManger { CustomFileManager() }

        @Option(name: .shortAndLong, help: "Path for configuration template to be created at")
        var path: String?

        func run() throws {
            let emptyConfiguration = InputConfiguration(
                executable: "",
                arguments: [""],
                projectRoot: "",
                includedFiles: [""],
                includedRules: [""],
                excludedFiles: [""],
                excludedRules: [""],
                options: [.verificationRun]
            )
            let data = try JSONEncoder().encode(emptyConfiguration)

            let fileManager: MutanusFileManger = CustomFileManager()

            let outputPath: String
            if let path = path {
                outputPath = path
            } else {
                outputPath = fileManager.currentDirectoryPath
            }

            fileManager.createFile(atPath: "\(outputPath)/MutanusConfig.json", contents: data)
        }
    }


    final class Run: ParsableCommand {
        private var fileManager: MutanusFileManger { CustomFileManager() }
        private var configuration: InputConfiguration?

        static let configuration = CommandConfiguration(abstract: "Starts Mutation testing")

        @Option(name: .shortAndLong, help: "Relative or absolute path to the configuration file")
        var configurationPath: String

        func run() throws {

            guard let configuration = configuration else {
                fatalError("Configuration hasn't been found")
            }

            let mutanusConfiguration = MutanusConfiguration(
                executable: configuration.executable,
                arguments: configuration.arguments,
                projectRoot: configuration.projectRoot ?? fileManager.currentDirectoryPath,
                includedFiles: configuration.includedFiles ?? [],
                includedRules: configuration.includedRules ?? [],
                excludedFiles: configuration.excludedFiles ?? [],
                excludedRules: configuration.excludedRules ?? [],
                options: configuration.options ?? []
            )

            Logger.logEvent(.receivedConfiguration(mutanusConfiguration))

            try MutanusHelper(
                configuration: mutanusConfiguration,
                executor: Executor(configuration: mutanusConfiguration),
                fileManager: fileManager,
                reportCompiler: ReportCompiler(configuration: mutanusConfiguration)
            ).start()
        }
    }
}

// MARK: - Validation
extension Mutanus.Run {
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
                throw ValidationError("Configuration file doesn't exits at given path")
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
            throw ValidationError("Project root path doesn't exist")
        }

        guard isDirectory else {
            throw ValidationError("Project root path is not a folder")
        }
    }
}

Mutanus.main()
