//
//  Created by Iurii Sorokin on 02.11.2021.
//

import Foundation
import ArgumentParser

struct Mutanus: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Performs Mutation testing of a Swift project",
        subcommands: [
            Run.self,
            CreateConfig.self,
            ExtractSources.self
        ]
    )
}

Mutanus.main()
