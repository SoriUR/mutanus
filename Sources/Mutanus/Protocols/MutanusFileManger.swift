//
//  Created by Iurii Sorokin on 07.11.2021.
//

import Foundation


protocol MutanusFileManger {

    var currentDirectoryPath: String { get }

    @discardableResult
    func changeCurrentDirectoryPath(_ path: String) -> Bool
    func contents(atPath path: String) -> Data?
    func subpaths(atPath path: String) -> [String]?

    func createMutanusDirectories()
    func createLogFile(name: String) -> URL
    func fileExists(atPath path: String) -> (exists: Bool, isDirectory: Bool)
    func createBackupFile(path: String)
    func restoreFileFromBackup(path: String)
    func createReportFile(contents: Data)
    func createFile(atPath path: String, contents data: Data)
}

final class CustomFileManager: FileManager, MutanusFileManger {
    func createMutanusDirectories() {
        createDirectory(atPath: logsDirectoryPath)
        createDirectory(atPath: backupsDirectoryPath)
    }

    func createLogFile(name: String) -> URL {
        let logPath = logsDirectoryPath + name
        createFile(atPath: logPath, contents: nil)
        return URL(fileURLWithPath: logPath)
    }

    func fileExists(atPath path: String) -> (exists: Bool, isDirectory: Bool)  {
        var isDirectory = ObjCBool(false)

        return (fileExists(atPath: path, isDirectory: &isDirectory), isDirectory.boolValue)
    }

    func createBackupFile(path: String) {
        let backupPath = backupFilePath(path: path)
        try! copyItem(atPath: path, toPath: backupPath)
    }

    func restoreFileFromBackup(path: String) {
        let backupFilePath = backupFilePath(path: path)
        try! removeItem(atPath: path)
        try! copyItem(atPath: backupFilePath, toPath: path)
        try! removeItem(atPath: backupFilePath)
    }

    func createReportFile(contents: Data) {
        createFile(atPath: mutanusDirectoryPath + "Report.json", contents: contents)
    }


    func createConfigurationFile(atPath: String, contents: Data) {
        createFile(atPath: mutanusDirectoryPath + "Report.json", contents: contents)
    }

    func createFile(atPath path: String, contents data: Data) {
        createFile(atPath: path, contents: data, attributes: [:])
    }


    // MARK: - Private

    private var logsDirectoryPath: String {
        mutanusDirectoryPath + "Logs/"
    }

    private var backupsDirectoryPath: String {
        mutanusDirectoryPath + "Backups/"
    }

    private lazy var mutanusDirectoryPath: String = {
        currentDirectoryPath + "/Mutanus/\(Date())/"
    }()

    private func createDirectory(atPath path: String) {
        let (exists, isDirectory) = fileExists(atPath: path)
        if exists && isDirectory {
            try! removeItem(atPath: path)
        }
        try! createDirectory(atPath: path, withIntermediateDirectories: true)
    }

    private func backupFilePath(path: String) -> String {
        backupsDirectoryPath + URL(fileURLWithPath: path).lastPathComponent
    }
}

