import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

enum DebugLogMacroError: Error, CustomStringConvertible {
    case missingMessage

    var description: String {
        "#debugLog requires a message argument"
    }
}

public struct DebugLogMacro: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> ExprSyntax {
        guard let messageArgument = node.arguments.first else {
            throw DebugLogMacroError.missingMessage
        }

        let messageExpr = ExprSyntax(messageArgument.expression)

        return """
        ({
            #if DEBUG
                NSLog("%@", String(describing: \(messageExpr)))
            #endif
        })()
        """
    }
}

@main
struct LoggerPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        DebugLogMacro.self,
    ]
}
