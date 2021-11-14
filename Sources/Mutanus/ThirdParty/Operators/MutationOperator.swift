import SwiftSyntax
import Foundation

typealias SourceCodeTransformation = (SourceFileSyntax) -> (mutatedSource: SyntaxProtocol, mutationSnapshot: MutationOperatorSnapshot)
typealias RewriterInitializer = (MutationPosition) -> PositionSpecificRewriter
typealias VisitorInitializer = (SourceFileInfo) -> PositionDiscoveringVisitor

public struct MutationPoint: Equatable, Codable {
    let `operator`: MutationOperator
    let position: MutationPosition
    
    var sourceTransformation: SourceCodeTransformation {
        return self.operator.mutationOperator(for: position)
    }
}

extension MutationPoint: Nullable {
    static var null: MutationPoint {
        MutationPoint(
            operator: .removeSideEffect,
            position: .null
        )
    }
}

enum MutationOperator: String, Codable, CaseIterable {
    case relationReplacement = "RelationalOperatorReplacement"
    case removeSideEffect = "RemoveSideEffects"
    case logicalConnector = "ChangeLogicalConnector"

    func visitor(_ info: SourceFileInfo) -> PositionDiscoveringVisitor {
        switch self {
        case .removeSideEffect:
            return RemoveSideEffectsOperator.Visitor(sourceFileInfo: info)

        case .relationReplacement:
            return ROROperator.Visitor(sourceFileInfo: info)

        case .logicalConnector:
            return ChangeLogicalConnectorOperator.Visitor(sourceFileInfo: info)
        }
    }

    func rewriter(_ position: MutationPosition) -> PositionSpecificRewriter {
        switch self {
        case .removeSideEffect:
            return RemoveSideEffectsOperator.Rewriter(positionToMutate: position)

        case .relationReplacement:
            return ROROperator.Rewriter(positionToMutate: position)

        case .logicalConnector:
            return ChangeLogicalConnectorOperator.Rewriter(positionToMutate: position)
        }
    }

    func mutationOperator(for position: MutationPosition) -> SourceCodeTransformation {
        return { source in
            let rewriter = self.rewriter(position)
            let mutatedSource = rewriter.visit(source)
            let operatorSnapshot = rewriter.operatorSnapshot
            return (
                mutatedSource: mutatedSource,
                mutationSnapshot: operatorSnapshot
            )
        }
    }
}

protocol PositionSpecificRewriter {
    var positionToMutate: MutationPosition { get }
    var operatorSnapshot: MutationOperatorSnapshot { get set }

    init(positionToMutate: MutationPosition)
    
    func visit(_ node: SourceFileSyntax) -> Syntax
}

protocol PositionDiscoveringVisitor {
    var positionsOfToken: [MutationPosition] { get }
    init(sourceFileInfo: SourceFileInfo)

    func walk<SyntaxType: SyntaxProtocol>(_ node: SyntaxType)
}
