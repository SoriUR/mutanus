//
//  ExtractSourceFilesStep.swift
//  Mutanus
//
//  Created by Iurii Sorokin on 03.11.2021.
//

import Foundation

final class ExtractSourceFilesStep: MutanusSequanceStep {

    typealias Context = Void
    typealias Result = [String]

    var next: AnyPerformsAction<Result>?

    let parameters: MutationParameters

    init(parameters: MutationParameters) {
        self.parameters = parameters
    }

    func performStep(_ context: Context) throws -> Result {
        var sourceFiles = [String]()

        let fileManager = FileManager.default

        parameters.files.forEach {
            let path = parameters.directory + $0
            let (exists, isDirectory) = fileManager.fileExists(atPath: path)

            guard exists else { return }

            let paths: [String] = isDirectory
                ? (fileManager.subpaths(atPath: path) ?? []).map { path + $0 }
                : [path]

            let filteredPaths = paths
                .filter { $0.hasSuffix(".swift") }
                .filter { !$0.contains("Tests") }
                .filter { !$0.contains("Seeds") }

            sourceFiles.append(contentsOf: filteredPaths)
        }

        return sourceFiles
    }
}
