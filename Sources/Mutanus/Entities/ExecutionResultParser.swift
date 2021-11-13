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

final class MutationResultParser: ExecutionResultParser {
    func recognizeResult(fileURL: URL, paths: [String]) -> (result: ExecutionResult, killed: Int, survived: Int) {
        let names = paths
            .map { String($0[$0.index($0.lastIndex(of: "/")!, offsetBy: 1)..<$0.firstIndex(of: ".")!]) + "Tests" }

        let result = recognizeResult(in: fileURL)

        guard
            result == .testFailed,
            let fileContent = try? String(contentsOf: fileURL),
            let index = fileContent.range(of: "Failing tests:")?.upperBound
        else {
            return (result, 0, names.count)
        }

        let rest = String(fileContent[index...])

        var killed: Int = 0

        names.forEach {
            if rest.range(of: $0) != nil {
                killed += 1
            }
        }

        return (result, killed, names.count - killed)
    }
}
