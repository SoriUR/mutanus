//
//  Created by Iurii Sorokin on 02.11.2021.
//

import Foundation

struct Executor {

    let configuration: MutanusConfiguration

    init(configuration: MutanusConfiguration) {
        self.configuration = configuration
    }

    func executeProccess(logURL: URL) throws {
        let logHandle = try FileHandle(forWritingTo: logURL)

        let process = Process()
        process.arguments = configuration.arguments
        process.executableURL = URL(fileURLWithPath: configuration.executable)
        process.standardOutput = logHandle
        process.standardError = logHandle

        try process.run()
        process.waitUntilExit()
        logHandle.closeFile()
    }
}
