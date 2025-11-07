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

        let categoryArgument = node.arguments.first { element in
            element.label?.text == "category"
        }

        let categoryExpr: ExprSyntax
        if let categoryArgument {
            categoryExpr = ExprSyntax(categoryArgument.expression)
        } else {
            categoryExpr = "nil"
        }

        let messageExpr = ExprSyntax(messageArgument.expression)

        return """
        DebugLoggerRuntime.emit(
            String(describing: \(messageExpr)),
            category: \(categoryExpr),
            fileID: #fileID,
            function: #function,
            line: #line
        )
        """
    }
}

@main
struct LoggerPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        DebugLogMacro.self,
    ]
}
