//
//  Created by Iurii Sorokin on 08.11.2021.
//

import Foundation

final class BackupFilesStep: MutanusSequenceStep {

    let fileManager: MutanusFileManger

    init(
        fileManager: MutanusFileManger,
        delegate: MutanusSequenceStepDelegate
    ) {
        self.fileManager = fileManager
        self.delegate = delegate
    }

    // MARK: - MutanusSequenceStep

    typealias Context = MutantsInfo
    typealias Result = MutantsInfo

    var next: AnyPerformsAction<Result>?
    weak var delegate: MutanusSequenceStepDelegate?

    func executeStep(_ context: Context) throws -> Result {
        for path in context.mutants.keys {
            fileManager.createBackupFile(path: path)
        }
        return context
    }
}
