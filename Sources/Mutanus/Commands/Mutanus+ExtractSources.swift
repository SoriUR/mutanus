//
//  Created by Iurii Sorokin on 08.03.2022.
//

import Foundation
import ArgumentParser

extension Mutanus {
    final class ExtractSources: ParsableCommand, PathValidator, ConfigValidator {

        static let configuration = CommandConfiguration(abstract: "Extracts sources for given configuration or ")
        var fileManager: MutanusFileManger { CustomFileManager() }

        @Option(name: .shortAndLong, help: "Relative or absolute path to the configuration file")
        var configPath: String

        func run() throws {

            let configuration = try validateConfig(atPath: configPath)

            Logger.logEvent(.receivedConfiguration(configuration))

            _ = try ExtractSourceFilesStep(
                fileManager: fileManager,
                configuration: configuration,
                delegate: self
            ).perform(.testSucceeded)
        }
    }
}

extension Mutanus.ExtractSources : MutanusSequenceStepDelegate {
    func stepStarted<T: ChainLink>(_ step: T) {
        switch step {
        case is ExtractSourceFilesStep:
            Logger.logEvent(.sourceFilesStarted)
        default:
            break
        }
    }

    func stepFinished<T: ChainLink>(_ step: T, result: T.Result) throws {

        switch step {
        case is ExtractSourceFilesStep:
            try handleSourcesStepResult(result as! ExtractSourceFilesStep.Result)
        default:
            break
        }
    }

    func handleSourcesStepResult(_ result: ExtractSourceFilesStep.Result) throws {
        Logger.logEvent(.sourceFilesFinished(sources: result))

        guard !result.isEmpty else { throw MutanusError.emptySources }
    }
}

// MARK: - Validation
extension Mutanus.ExtractSources {
    func validate() throws {
        configPath = try validatePath(configPath)
    }
}
