//
//  FindMutantsStep.swift
//  Mutanus
//
//  Created by Iurii Sorokin on 03.11.2021.
//

import Foundation

final class FindMutantsStep: MutanusSequanceStep {
    typealias Context = [String]
    typealias Result = [String: [String]]

    var next: AnyPerformsAction<Result>?

    func performStep(_ context: Context) throws -> Result {
        var result = [String: [String]]()
        context.forEach {
            result[$0] = [] // TODO
        }
        return result
    }
}
