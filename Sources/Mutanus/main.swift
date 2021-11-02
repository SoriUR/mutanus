import Foundation
import ArgumentParser

@available(OSX 10.13, *)
struct Entry: ParsableCommand {

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
        let mapped = files.map { "-only-testing:\(scheme)-Unit-Tests/\($0)" }

        print("""
                directory: \(resultDirectory)
                executable: \(executable)
                workspace: \(workspace)
                scheme: \(scheme)
                command: \(executable) test -workspace \(workspace).xcworkspace -scheme \(scheme) -destination "platform=iOS Simulator,name=iPhone 8" \(mapped.joined(separator: " "))
            """)

        let mutanus = Mutanus(parameters: .init(
            directory: resultDirectory,
            executable: executable,
            arguments: [
                "test",
                "-workspace",
                "\(workspace).xcworkspace",
                "-scheme", "\(scheme)",
                "-destination",
                "platform=iOS Simulator,name=iPhone 8"
            ] + mapped,
            files: files
        ))

        try mutanus.start()
    }
}

// MARK: - Validation
@available(OSX 10.13, *)
extension Entry {
    func validate() throws {
        try validateDirectory(directory)
        try validateExecutable(executable)
    }

    // MARK: - Private

    private func validateDirectory(_ path: String?) throws {
        guard let path = path else { return }

        let (exists, isDirectory) = fileExists(atPath: path)
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

    private func fileExists(atPath path: String) -> (exists: Bool, isDirectory: Bool)  {
        var isDirectory = ObjCBool(false)

        return (FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory), isDirectory.boolValue)
    }
}


if #available(macOS 10.13, *) {
    Entry.main()
} else {
    print("macOS versions under 10.13 are not supported")
}
