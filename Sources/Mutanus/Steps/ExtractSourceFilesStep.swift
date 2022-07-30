//
//  Created by Iurii Sorokin on 03.11.2021.
//

import Foundation

final class ExtractSourceFilesStep: MutanusSequenceStep {

    typealias Context = ExecutionResult
    typealias Result = [String]

    let configuration: MutanusConfiguration
    let fileManager: MutanusFileManger

    init(
        fileManager: MutanusFileManger,
        configuration: MutanusConfiguration,
        delegate: MutanusSequenceStepDelegate?
    ) {
        self.fileManager = fileManager
        self.configuration = configuration
        self.delegate = delegate
    }

    // MARK: - MutanusSequenceStep

    var next: AnyPerformsAction<Result>?

    weak var delegate: MutanusSequenceStepDelegate?

    func executeStep(_ context: Context) throws -> Result {
        let notExcluded = extractNotExcludedFiles()
        let includedAndNotExcluded = extractIncludedFiles(from: notExcluded)

        return includedAndNotExcluded
    }
}

// MARK: - Private
private extension ExtractSourceFilesStep {

    func extractNotExcludedFiles() -> [String] {
        return extractSources(at: "/").compactMap { path in

            // Исключаем, если есть в excludedFiles
            for excludedPath in configuration.excludedFiles {
                if path.contains(excludedPath) { return nil }
            }

            // Исключаем, если подходит под excludedRules
            for rule in configuration.excludedRules {
                if path.range(of: rule, options: .regularExpression) != nil { return nil }
            }

            return path
        }
    }

    func extractIncludedFiles(from sources: [String]) -> [String] {

        // Если нет правил, то возвращаем все
        guard !configuration.includedFiles.isEmpty || !configuration.includedRules.isEmpty else {
            return sources
        }

        return sources.compactMap { path in

            // Добавляем, если в includedFiles
            for includedPath in configuration.includedFiles {
                if path.contains(includedPath) { return path }
            }

            // Добавляем, если подходит под includedRules
            for rule in configuration.includedRules {
                if path.range(of: rule, options: .regularExpression) != nil { return path }
            }

            return nil
        }
    }

    func extractSources(at subPath: String) -> [String] {
        let path = configuration.projectRoot + subPath
        let (exists, isDirectory) = fileManager.fileExists(atPath: path)

        guard exists else { return [] }

        let paths: [String] = isDirectory
            ? (fileManager.subpaths(atPath: path) ?? []).map { path + $0 }
            : [path]

        return paths.filter { $0.hasSuffix(".swift") }
    }
}
