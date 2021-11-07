//
//  Created by Iurii Sorokin on 02.11.2021.
//

import Foundation

struct Executor {

    let parameters: MutationParameters

    init(parameters: MutationParameters) {
        self.parameters = parameters
    }

    func executeProccess(logURL: URL) throws {
        let logHandle = try FileHandle(forWritingTo: logURL)

        let process = Process()
        process.arguments = parameters.arguments
        process.executableURL = URL(fileURLWithPath: parameters.executable)
        process.standardOutput = logHandle
        process.standardError = logHandle

        try process.run()
        process.waitUntilExit()
        logHandle.closeFile()
    }
}
