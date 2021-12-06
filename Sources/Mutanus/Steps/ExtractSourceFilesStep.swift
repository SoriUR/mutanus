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

        configuration.sourceFiles.forEach {
            let path = configuration.projectRoot + $0
            let (exists, isDirectory) = fileManager.fileExists(atPath: path)

            guard exists else { return }

            let paths: [String] = isDirectory
                ? (fileManager.subpaths(atPath: path) ?? []).map { path + $0 }
                : [path]

            let filteredPaths = paths
                .filter { $0.hasSuffix(".swift") }
                .filter { path in
                    configuration.excludedFiles.reduce(true) { result, current in
                        return result && path.range(of: current, options: .regularExpression) == nil
                    }
                }

            sourceFiles.append(contentsOf: filteredPaths)
        }

        return sourceFiles
    }
}
