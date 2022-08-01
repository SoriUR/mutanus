//  Created by Юра Сорокин  on 31.07.2022.

import Foundation
import ArgumentParser

protocol PathValidator {
    var fileManager: MutanusFileManger { get }

    func validatePath(_ path: String) throws -> String
}

extension PathValidator {

    func validatePath(_ path: String) throws -> String {

        var (exists, isDirectory) = fileManager.fileExists(atPath: path)

        if exists, !isDirectory {
            return path
        }

        let relativeConfigurationPath = fileManager.currentDirectoryPath + "/\(path)"
        (exists, isDirectory) = fileManager.fileExists(atPath: relativeConfigurationPath)

        if exists, !isDirectory {
            return relativeConfigurationPath
        }

        throw ValidationError("File doesn't exits at: \(path)")
    }
}
