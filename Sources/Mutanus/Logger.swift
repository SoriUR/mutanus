//
//  Created by Iurii Sorokin on 02.11.2021.
//

import Foundation

enum LoggerEvent {
    case receivedParameters(MutationParameters)
    case referenceRunStart
    case referenceRunFinished(duration: TimeInterval, result: ExecutionResult)
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

        case let .referenceRunFinished(duration, result):
            logReferenceRunFinished(duration, result)

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

    private static func logReceivedParameters(_ parameters: MutationParameters) {
        let content = """
            directory: \(parameters.directory)
            executable: \(parameters.executable)
            arguments: \(parameters.arguments.joined(separator: " "))
        """

        printOutput(title: "Mutanus Parameters", content: content)
    }

    private static func logReferenceRunFinished(_ duration: TimeInterval, _ result: ExecutionResult) {
        let content = """
            Duration: \(duration.rounded()) sec
            Result: \(result.pretty)
        """
        printOutput(title: nil, content: content)
    }

    private static func logMutationIterationFinished(_ duration: TimeInterval, _ result: ExecutionResult) {
        let content = """
            Duration: \(duration.rounded()) sec
            Result: \(result.pretty)
        """
        printOutput(title: nil, content: content)
    }

    private static func logMutationTestingFinished(
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
        """

        printOutput(title: "Mutation Testing Result", content: content)
    }

    private static func printOutput(title: String?, content: String? = nil) {

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
