//
//  Created by Iurii Sorokin on 03.11.2021.
//

import Foundation

final class ExtractSourceFilesStep: MutanusSequanceStep {

    typealias Context = ExecutionResult
    typealias Result = [String]

    let parameters: MutationParameters
    let fileManager: MutanusFileManger

    init(
        fileManager: MutanusFileManger,
        parameters: MutationParameters,
        delegate: MutanusSequanceStepDelegate?
    ) {
        self.fileManager = fileManager
        self.parameters = parameters
        self.delegate = delegate
    }

    // MARK: - MutanusSequanceStep

    var next: AnyPerformsAction<Result>?
    weak var delegate: MutanusSequanceStepDelegate?

    func executeStep(_ context: Context) throws -> Result {
        var sourceFiles = [String]()

        let fileManager = FileManager.default

        parameters.files.forEach {
            let path = fileManager.currentDirectoryPath + $0
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
