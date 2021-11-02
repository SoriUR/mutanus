//
//  Created by Iurii Sorokin on 02.11.2021.
//

import Foundation

struct MutationParameters {
    let directory: String
    let executable: String
    let arguments: [String]
    let files: [String]
}

struct Mutanus {

    let parameters: MutationParameters

    init(parameters: MutationParameters) {
        self.parameters = parameters
    }

    func start() throws {
        let logFilePath = parameters.directory + "/logFile2.txt"
        FileManager.default.createFile(atPath: logFilePath, contents: nil)
        let fileURL = URL(fileURLWithPath: logFilePath)
        let fileHandle = try FileHandle(forWritingTo: fileURL)

        let process = Process()
        process.arguments = parameters.arguments
        process.executableURL = URL(fileURLWithPath: parameters.executable)
        process.standardOutput = fileHandle
        process.standardError = fileHandle

        let startTime = Date()

        try process.run()
        process.waitUntilExit()

        let duration = startTime.distance(to: Date())

        fileHandle.closeFile()

        let executionResult = ExecutionResultParser.recognizeResult(in: fileURL)

        print("""
            buildDuration: \(duration.rounded()) sec
            executionResult: \(executionResult.pretty)
            """)
    }
}
