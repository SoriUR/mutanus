//
//  Created by Iurii Sorokin on 02.11.2021.
//

import Foundation

struct ExecutionResultParser {
    static func recognizeResult(in url: URL) -> ExecutionResult {
        let fileContent = try! String(contentsOf: url)
        
        for item in ExecutionResult.allCases {
            if fileContent.contains(getAttribute(for: item)) {
                return item
            }
        }
        
        return .testSucceeded
    }
    
    private static func getAttribute(for result: ExecutionResult) -> String {
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
