//
//  Created by Iurii Sorokin on 02.11.2021.
//

import Foundation

struct MutationParameters {
    let directory: String
    let executable: String
    let arguments: [String]
    let files: [String]
}

struct Mutanus {

    let parameters: MutationParameters
    let executor: Executor

    init(
        parameters: MutationParameters,
        executor: Executor
    ) {
        self.parameters = parameters
        self.executor = executor
    }

    func start() throws {

        FileManager.default.changeCurrentDirectoryPath(parameters.directory)

        let sequence = StepsSequence()

        sequence
            .next(ReferenceRunStep(parameters: parameters, executor: executor))
            .next(ExtractSourceFilesStep(parameters: parameters))
            .next(FindMutantsStep())
            .next(MutationTestingStep(parameters: parameters, executor: executor))

        try sequence.start()
    }
}
