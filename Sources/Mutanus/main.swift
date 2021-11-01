import Foundation
import ArgumentParser

struct Mutanus: ParsableCommand {

    @Option var path: String?

    func validate() throws {
        guard let path = path else { return }

        var isDirectory = ObjCBool(true)
        guard FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory) else {
            throw ValidationError("Path doesn't exist")
        }

        guard isDirectory.boolValue else {
            throw ValidationError("Path is not a folder")
        }
    }

    func run() throws {
        if let path = path {
            print("custom path: \(path)")
        } else {
            print("default path: \(FileManager.default.currentDirectoryPath)")
        }
    }
}

Mutanus.main()
