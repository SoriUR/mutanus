//
//  Created by Iurii Sorokin on 03.11.2021.
//

import Foundation

final class ExtractSourceFilesStep: MutanusSequanceStep {

    typealias Context = ExecutionResult
    typealias Result = [String]

    let configuration: MutanusConfiguration
    let fileManager: MutanusFileManger

    init(
        fileManager: MutanusFileManger,
        configuration: MutanusConfiguration,
        delegate: MutanusSequanceStepDelegate?
    ) {
        self.fileManager = fileManager
        self.configuration = configuration
        self.delegate = delegate
    }

    // MARK: - MutanusSequanceStep

    var next: AnyPerformsAction<Result>?
    weak var delegate: MutanusSequanceStepDelegate?

    func executeStep(_ context: Context) throws -> Result {
        var sourceFiles = [String]()

        configuration.sourcePaths.forEach {
            let path = configuration.projectPath + $0
            let (exists, isDirectory) = fileManager.fileExists(atPath: path)

            guard exists else { return }

            let paths: [String] = isDirectory
                ? (fileManager.subpaths(atPath: path) ?? []).map { path + $0 }
                : [path]

            let filteredPaths = paths
                .filter { $0.hasSuffix(".swift") }
                .filter { !$0.contains("Tests") }
                .filter { !$0.contains("Seeds") }
                .filter { !$0.contains("Snapshots") }
                .filter { !$0.contains("View.swift") }

            sourceFiles.append(contentsOf: filteredPaths)
        }

        return sourceFiles
    }
}
