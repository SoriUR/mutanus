import Foundation
import ArgumentParser

struct Entry: ParsableCommand {

    private var fileManager: MutanusFileManger { FileManager.default }

    @Option(name: .shortAndLong, help: "Path to the configuration file")
    var configurationPath: String?

    @Option(name: .shortAndLong, help: "Path to the executable")
    var executable: String?

    @Option(name: .shortAndLong, parsing: .upToNextOption, help: "Arguments for executable", completion: nil)
    var arguments: [String] = []

    @Option(name: .shortAndLong, help: "Path to the project root")
    var projectPath: String?

    @Option(name: .shortAndLong, parsing: .upToNextOption, help: "Files to find mutants in", completion: nil)
    var sourcePaths: [String] = []

    func run() throws {

        let configuration: MutanusConfiguration

        if
            let configurationPath = configurationPath,
            let data = fileManager.contents(atPath: configurationPath)
        {
            configuration = try JSONDecoder().decode(MutanusConfiguration.self, from: data)
        } else if let executable = executable {
            configuration = MutanusConfiguration(
                executable: executable,
                arguments: arguments,
                projectPath: projectPath ?? fileManager.currentDirectoryPath,
                sourcePaths: sourcePaths
            )
        } else {
            fatalError("Neither configuration or executable has beed found")
        }

        Logger.logEvent(.receivedConfiguration(configuration))

        try Mutanus(
            configuration: configuration,
            executor: Executor(configuration: configuration),
            fileManager: fileManager,
            reportCompiler: ReportCompiler(configuration: configuration)
        ).start()
    }
}

// MARK: - Validation
extension Entry {
    func validate() throws {
        if let configurationPath = configurationPath {

            let (exists, isDirectory) = fileManager.fileExists(atPath: configurationPath)

            guard exists, !isDirectory else {
                throw ValidationError("Configuration file at given path doesn't exits")
            }
            return
        }

        try validateDirectory(projectPath)
        try validateExecutable(executable)
    }

    // MARK: - Private

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

    private func validateExecutable(_ path: String?) throws {
        guard let executablePath = executable else {
            throw ValidationError("Executable has't been specified")
        }

        guard FileManager.default.isExecutableFile(atPath: executablePath) else {
            throw ValidationError("Executable doesn't exist")
        }
    }
}

Entry.main()
