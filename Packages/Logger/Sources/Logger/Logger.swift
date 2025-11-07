import Foundation

@freestanding(expression)
public macro debugLog(
    _ message: Any,
    category: String? = nil
) = #externalMacro(module: "LoggerMacros", type: "DebugLogMacro")

public enum DebugLoggerRuntime {
    public static func emit(
        _ message: @autoclosure () -> String,
        category: String? = nil,
        fileID: StaticString,
        function: String,
        line: Int
    ) {
#if DEBUG
        let location = "\(String(describing: fileID)):\(line) \(function)"
        guard let category = category else {
            NSLog("%@", message())
            return
        }
        let payload = "\(category)\(location) — \(message())"
        NSLog("%@", payload)
#endif
    }
}
