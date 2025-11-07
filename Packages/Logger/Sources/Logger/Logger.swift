import Foundation

@freestanding(expression)
public macro debugLog(
    _ message: Any,
    category: String? = nil
) = #externalMacro(module: "LoggerMacros", type: "DebugLogMacro")
