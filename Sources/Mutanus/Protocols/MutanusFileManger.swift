//
//  Created by Iurii Sorokin on 07.11.2021.
//

import Foundation


protocol MutanusFileManger {

    var currentDirectoryPath: String { get }

    func createEmptyFile(atPath path: String)
    func logFilePath(appending: String) -> String

    @discardableResult
    func changeCurrentDirectoryPath(_ path: String) -> Bool

    func fileExists(atPath path: String) -> (exists: Bool, isDirectory: Bool)
}

extension FileManager: MutanusFileManger {

    func logFilePath(appending: String) -> String {
        currentDirectoryPath + "/" + appending
    }

    func createEmptyFile(atPath path: String) {
        createFile(atPath: path, contents: nil)
    }

    func fileExists(atPath path: String) -> (exists: Bool, isDirectory: Bool)  {
        var isDirectory = ObjCBool(false)

        return (fileExists(atPath: path, isDirectory: &isDirectory), isDirectory.boolValue)
    }
    
}
