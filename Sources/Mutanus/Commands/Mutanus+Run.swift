//
//  Created Iurii Sorokin on 08.03.2022.
//

import ArgumentParser
import Foundation

extension Mutanus {
    final class Run: ParsableCommand, PathValidator, ConfigValidator {

        static let configuration = CommandConfiguration(abstract: "Starts Mutation testing")
        lazy var fileManager: MutanusFileManger = CustomFileManager()

        @Argument(help: "Relative or absolute path to the configuration file")
        var configPath: String

        func run() throws {

            let configuration = try validateConfig(atPath: configPath)

            Logger.logEvent(.receivedConfiguration(configuration))

            try MutanusHelper(
                configuration: configuration,
                executor: Executor(configuration: configuration),
                fileManager: fileManager,
                reportCompiler: ReportCompiler(configuration: configuration)
            ).start()
        }
    }
}

// MARK: - Validation
extension Mutanus.Run {
    func validate() throws {
        configPath = try validatePath(configPath)
    }
}
