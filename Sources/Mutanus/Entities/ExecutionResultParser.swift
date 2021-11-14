//
//  Created by Iurii Sorokin on 02.11.2021.
//

import Foundation

class ExecutionResultParser {
    func recognizeResult(in url: URL) -> ExecutionResult {
        let fileContent = try! String(contentsOf: url)
        
        for item in ExecutionResult.allCases {
            if fileContent.contains(getAttribute(for: item)) {
                return item
            }
        }
        
        return .testSucceeded
    }
    
    private func getAttribute(for result: ExecutionResult) -> String {
        switch result {
        case .buildFailed: return "Testing cancelled because the build failed"
        case .testFailed: return "** TEST FAILED **"
        case .testSucceeded: return "** TEST SUCCEEDED **"
        }
    }
}

enum ExecutionResult: CaseIterable {
    case buildFailed
    case testSucceeded
    case testFailed
    
    var pretty: String {
        switch self {
        case .buildFailed: return "Build Failed"
        case .testSucceeded: return "Test Succeeded"
        case .testFailed: return "Test Failed"
        }
    }
}

struct ExecutionReport {
    let result: ExecutionResult
    let killed: [String]
    let survived: [String]
}

final class MutationResultParser: ExecutionResultParser {
    func recognizeResult(fileURL: URL, paths: [String]) -> ExecutionReport {
        let testFilesNames = paths
            .map { String($0[$0.index($0.lastIndex(of: "/")!, offsetBy: 1)..<$0.firstIndex(of: ".")!]) + "Tests" }

        let result = recognizeResult(in: fileURL)

        guard
            result == .testFailed,
            let fileContent = try? String(contentsOf: fileURL),
            let index = fileContent.range(of: "Failing tests:")?.upperBound
        else {
            return .init(result: result, killed: [], survived: testFilesNames)
        }

        let errorsTestRange = String(fileContent[index...])

        var killed: [String] = []
        var survived: [String] = []

        testFilesNames.forEach {
            if errorsTestRange.range(of: $0) != nil {
                killed += [$0]
            } else {
                survived += [$0]
            }
        }

        return .init(
            result: result,
            killed: killed,
            survived: survived
        )
    }
}
