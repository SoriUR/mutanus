//
//  Created by Iurii Sorokin on 08.03.2022.
//

import Foundation
import ArgumentParser

extension Mutanus {
    struct CreateConfig: ParsableCommand {

        static let configuration = CommandConfiguration(abstract: "Creates configuration file")

        private var fileManager: MutanusFileManger { CustomFileManager() }

        @Argument(help: "Path for configuration template to be created at")
        var path: String?

        func run() throws {
            let emptyConfiguration = InputConfiguration(
                executable: "",
                arguments: [""],
                projectRoot: "",
                includedFiles: [""],
                includedRules: [""],
                excludedFiles: [""],
                excludedRules: [""],
                options: [.verificationRun]
            )
            let data = try JSONEncoder().encode(emptyConfiguration)

            let fileManager: MutanusFileManger = CustomFileManager()

            let outputPath: String
            if let path = path {
                outputPath = path
            } else {
                outputPath = fileManager.currentDirectoryPath
            }

            fileManager.createFile(atPath: "\(outputPath)/MutanusConfig.json", contents: data)
        }
    }
}
