//
//  Created by Iurii Sorokin on 02.11.2021.
//

import Foundation

struct Executor {

    struct Info {
        let duration: TimeInterval
        let logURL: URL
    }

    func executeProccess(with parameters: MutationParameters) throws -> Info {

        let logPath = parameters.directory + "/" + Constants.logFileName
        FileManager.default.createFile(atPath: logPath, contents: nil)
        let logURL = URL(fileURLWithPath: logPath)
        let logHandle = try FileHandle(forWritingTo: logURL)

        let process = Process()
        process.arguments = parameters.arguments
        process.executableURL = URL(fileURLWithPath: parameters.executable)
        process.standardOutput = logHandle
        process.standardError = logHandle

        let startTime = Date()

        try process.run()
        process.waitUntilExit()

        let duration = startTime.distance(to: Date())

        logHandle.closeFile()

        return Info(
            duration: duration,
            logURL: logURL
        )
    }
}

private extension Executor {
    enum Constants {
        static let logFileName = "MutanusExecutionLogFile"
    }
}
