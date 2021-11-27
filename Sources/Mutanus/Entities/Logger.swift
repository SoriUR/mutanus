//
//  Created by Iurii Sorokin on 02.11.2021.
//

import Foundation

enum LoggerEvent {
    case receivedConfiguration(MutanusConfiguration)

    case referenceRunStarted
    case referenceRunFinished(result: ExecutionResult)

    case sourceFilesStarted
    case sourceFilesFinished(sources: [String])

    case findMutantsStarted
    case findMutantsFinished(result: MutantsInfo)

    case filesBackupStared

    case mutationTestingStarted
    case mutationTestingFinished(total: Int, killed: Int)

    case mutationIterationStarted(index: Int)
    case mutationIterationFinished(duration: TimeInterval, result: ExecutionReport)
}

enum Logger  {

    static var isEnabled = true

    static func logEvent(_ event: LoggerEvent) {
        switch event {
        case let .receivedConfiguration(parameters):
            logReceivedParameters(parameters)

        case .referenceRunStarted:
            printOutput(title: "Runing reference tests")

        case let .referenceRunFinished(result):
            logReferenceRunFinished(result)

        case .sourceFilesStarted:
            printOutput(title: "Extracting source files")

        case let .sourceFilesFinished(result):
            logSourceFilesFinished(result)

        case .findMutantsStarted:
            printOutput(title: "Searching for Mutants")

        case let .findMutantsFinished(result):
            logFindMutantsFinished(result)

        case .filesBackupStared:
            printOutput(title: "Making file backups")

        case .mutationTestingStarted:
            printOutput(title: "Executing mutation testing")

        case let .mutationTestingFinished(total, killed):
            logMutationTestingFinished(total, killed)

        case let .mutationIterationStarted(index):
            printOutput(title: "Mutation iterations Number: \(index)")

        case let .mutationIterationFinished(duration, result):
            logMutationIterationFinished(duration, result)
        }
    }

    static func logStepDuration(_ duration: TimeInterval) {
        print(String(format: "\n    Step Duration: %.2f sec", duration))
    }

    static func logTotalDuration(_ duration: TimeInterval) {
        print(String(format: "\n    Total Duration: %.2f sec", duration))
    }


}

// MARK: - Private
private extension Logger {

    static func logReceivedParameters(_ parameters: MutanusConfiguration) {
        let content = """
            directory: \(parameters.projectPath)
            executable: \(parameters.executable)
            arguments: \(parameters.arguments.joined(separator: " "))
        """

        printOutput(title: "Mutanus Parameters", content: content)
    }

    static func logReferenceRunFinished(_ result: ExecutionResult) {
        let content = """
            Result: \(result.pretty)
        """
        printOutput(title: nil, content: content)
    }

    static func logSourceFilesFinished(_ result: [String]) {
        let str = result.reduce(into: "") { result, current in
            result += "    \(URL(fileURLWithPath: current).lastPathComponent)\n"
        }
        let content = """
        \(str)
        """
        printOutput(title: nil, content: content)
    }

    static func logFindMutantsFinished(_ result: MutantsInfo) {
        var str = ""
        for (key, value) in result.mutants {
            str += "    \(URL(fileURLWithPath: key).lastPathComponent): \(value.1.count) mutants\n"
        }
        let content = """
            Total Mutants: \(result.totalCount)
            Max Mutants in a file: \(result.maxFileCount)

        \(str)
        """
        printOutput(title: nil, content: content)
    }

    static func logMutationIterationFinished(_ duration: TimeInterval, _ result: ExecutionReport) {
        let content = """
            Result: \(result.result.pretty)
            Found: \(result.total)
            Killed: \(result.killed.count)
            Duration: \(duration.rounded()) sec

        """
        printOutput(title: nil, content: content)
    }

    static func logMutationTestingFinished(
        _ total: Int,
        _ killed: Int
    ) {
        let score = Float(killed)/Float(total) * 100
        let content = """
            Mutants Count: \(total)
            Mutants Killed: \(killed)
            \(String(format: "Mutation Score: %.2f", score))%
        """

        printOutput(title: "Mutation Testing Result", content: content)
    }

    static func printOutput(title: String?, content: String? = nil) {

        guard isEnabled else { return }

        if let title = title {
            print("""

                --- \(title) ---
            """)
        }

        if let content = content {
            print("\n" + content)
        }
    }
}
