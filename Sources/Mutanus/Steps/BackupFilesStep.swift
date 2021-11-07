//
//  Created by Iurii Sorokin on 08.11.2021.
//

import Foundation

final class BackupFilesStep: MutanusSequanceStep {

    let fileManager: MutanusFileManger

    init(
        fileManager: MutanusFileManger,
        delegate: MutanusSequanceStepDelegate
    ) {
        self.fileManager = fileManager
        self.delegate = delegate
    }

    // MARK: - MutanusSequanceStep

    typealias Context = MutantsInfo
    typealias Result = MutantsInfo

    var next: AnyPerformsAction<Result>?
    var delegate: MutanusSequanceStepDelegate?

    func executeStep(_ context: Context) throws -> Result {
        for path in context.mutants.keys {
            fileManager.createBackupFile(path: path)
        }
        return context
    }
}
