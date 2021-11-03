import SwiftSyntax
import Foundation

typealias SourceCodeTransformation = (SourceFileSyntax) -> (mutatedSource: SyntaxProtocol, mutationSnapshot: MutationOperatorSnapshot)
typealias RewriterInitializer = (MutationPosition) -> PositionSpecificRewriter
typealias VisitorInitializer = (SourceFileInfo) -> PositionDiscoveringVisitor

public struct MutationPoint: Equatable, Codable {
    let mutationOperatorId: MutationOperator.Id
    let filePath: String
    let position: MutationPosition
    
    var fileName: String {
        return URL(fileURLWithPath: self.filePath).lastPathComponent
    }
    
    var mutationOperator: SourceCodeTransformation {
        return mutationOperatorId.mutationOperator(for: position)
    }
}

extension MutationPoint: Nullable {
    static var null: MutationPoint {
        MutationPoint(
            mutationOperatorId: .removeSideEffects,
            filePath: "",
            position: .null
        )
    }
}

struct MutationOperator {
    public enum Id: String, Codable, CaseIterable {
        case ror = "RelationalOperatorReplacement"
        case removeSideEffects = "RemoveSideEffects"
        case logicalOperator = "ChangeLogicalConnector"

        func visitor(_ info: SourceFileInfo) -> PositionDiscoveringVisitor {
            switch self {
            case .removeSideEffects:
               return RemoveSideEffectsOperator.Visitor(sourceFileInfo: info)

            case .ror:
                return ROROperator.Visitor(sourceFileInfo: info)

            case .logicalOperator:
                return ChangeLogicalConnectorOperator.Visitor(sourceFileInfo: info)
            }
        }

        func rewriter(_ position: MutationPosition) -> PositionSpecificRewriter {
            switch self {
            case .removeSideEffects:
               return RemoveSideEffectsOperator.Rewriter(positionToMutate: position)

            case .ror:
                return ROROperator.Rewriter(positionToMutate: position)

            case .logicalOperator:
                return ChangeLogicalConnectorOperator.Rewriter(positionToMutate: position)
            }
        }
        
        func mutationOperator(for position: MutationPosition) -> SourceCodeTransformation {
            return { source in
                let visitor = self.rewriter(position)
                let mutatedSource = visitor.visit(source)
                let operatorSnapshot = visitor.operatorSnapshot
                return (
                    mutatedSource: mutatedSource,
                    mutationSnapshot: operatorSnapshot
                )
            }
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
