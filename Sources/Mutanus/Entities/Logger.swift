//
//  Created by Iurii Sorokin on 02.11.2021.
//

import Foundation

enum LoggerEvent {
    case receivedParameters(MutationParameters)
    case referenceRunStart
    case referenceRunFinished(result: ExecutionResult)
    case mutationTestingStarted(count: Int)
    case mutationTestingFinished(duration: TimeInterval, total: Int, killed: Int, survived: Int)
    case mutationIterationStarted(index: Int)
    case mutationIterationFinished(duration: TimeInterval, result: ExecutionResult)
}

enum Logger  {

    static func logEvent(_ event: LoggerEvent) {
        switch event {
        case .referenceRunStart:
            printOutput(title: "Reference Run Started")

        case let .referenceRunFinished(result):
            logReferenceRunFinished(result)

        case let .receivedParameters(parameters):
            logReceivedParameters(parameters)

        case let .mutationTestingStarted(count):
            printOutput(title: "Mutation Testing Started. Total Iterations Count: \(count)")

        case let .mutationTestingFinished(duration, total, killed, survived):
            logMutationTestingFinished(duration, total, killed, survived)

        case let .mutationIterationStarted(index):
            printOutput(title: "Mutation Iterations Number: \(index)")

        case let .mutationIterationFinished(duration, result):
            logMutationIterationFinished(duration, result)
        }
    }

    static func logStepDuration(_ duration: TimeInterval) {
        print(String(format: "    Step Duration: %.2f", duration))
    }
}

// MARK: - Private
private extension Logger {

    static func logReceivedParameters(_ parameters: MutationParameters) {
        let content = """
            directory: \(parameters.directory)
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

    static func logMutationIterationFinished(_ duration: TimeInterval, _ result: ExecutionResult) {
        let content = """
            Duration: \(duration.rounded()) sec
            Result: \(result.pretty)
        """
        printOutput(title: nil, content: content)
    }

    static func logMutationTestingFinished(
        _ duration: TimeInterval,
        _ total: Int,
        _ killed: Int,
        _ survived: Int
    ) {
        let content = """
            Duration: \(duration.rounded()) sec
            Mutants Count: \(total)
            Mutants Killed: \(killed)
            Mutants Survived: \(survived)
            Mutation Score: \(Float(killed)/Float(total))

        """

        printOutput(title: "Mutation Testing Result", content: content)
    }

    static func printOutput(title: String?, content: String? = nil) {

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
