import Foundation
import ArgumentParser

struct Entry: ParsableCommand {

    private var fileManager: MutanusFileManger { FileManager.default }

    @Option(name: .shortAndLong, help: "Path to project root")
    var directory: String?

    @Option(name: .shortAndLong, help: "Path to the executable")
    var executable: String = "/usr/bin/xcodebuild"

    @Option(name: .shortAndLong, help: "Name of the workspace")
    var workspace: String

    @Option(name: .shortAndLong, help: "Name of the scheme")
    var scheme: String

    @Option(name: .shortAndLong, parsing: .upToNextOption, help: "Files to find mutants in", completion: nil)
    var files: [String] = []

    func run() throws {
        let resultDirectory = directory ?? FileManager.default.currentDirectoryPath

        let onlyTesting = files.map { "-only-testing:\(scheme)-Unit-Tests/\($0)" }

        let parameters = MutationParameters(
            directory: resultDirectory,
            executable: executable,
            arguments: [
                "test",
                "-workspace",
                "\(workspace).xcworkspace",
                "-scheme", "\(scheme)",
                "-destination",
                "platform=iOS Simulator,name=iPhone 8",
                "SWIFT_TREAT_WARNINGS_AS_ERRORS=NO",
                "GCC_TREAT_WARNINGS_AS_ERRORS=NO"
            ],
            files: files
        )

        Logger.logEvent(.receivedParameters(parameters))

        try Mutanus(
            parameters: parameters,
            executor: Executor(parameters: parameters),
            fileManager: fileManager
        ).start()
    }
}

// MARK: - Validation
extension Entry {
    func validate() throws {
        try validateDirectory(directory)
        try validateExecutable(executable)
    }

    // MARK: - Private

    private func validateDirectory(_ path: String?) throws {
        guard let path = path else { return }

        let (exists, isDirectory) = FileManager.default.fileExists(atPath: path)
        guard exists  else {
            throw ValidationError("Path doesn't exist")
        }

        guard isDirectory else {
            throw ValidationError("Path is not a folder")
        }
    }

    private func validateExecutable(_ path: String) throws {
        guard FileManager.default.isExecutableFile(atPath: path) else {
            throw ValidationError("Executable doesn't exist")
        }
    }
}

Entry.main()
