import Foundation
import os

public enum XLogCatogory: String {
    case common
    case network
    case database
}

public struct XLog: Sendable {
    private let logger: Logger
    
    public init(
        subsystem: String = Bundle.main.bundleIdentifier ?? "com.gemwallet.ios.xlog",
        category: String = XLogCatogory.common.rawValue
    ) {
        self.logger = Logger(
            subsystem: subsystem,
            category: category
        )
    }
    
    enum LogLevel {
        case info
        case warning
        case error
        case debug
        
        var osLogType: OSLogType {
            switch self {
            case .info: return .info
            case .warning: return .default
            case .error: return .error
            case .debug: return .debug
            }
        }
        
        var prefix: String {
            switch self {
            case .info: return "ℹ️ INFO"
            case .warning: return "⚠️ WARN"
            case .error: return "❌ ERROR"
            case .debug: return "🍏 DEBUG"
            }
        }
    }
    
    struct Context {
        let file: String
        let function: String
        let line: Int
        
        var description: String {
            return "\((file as NSString).lastPathComponent):\(line) \(function)"
        }
    }
    
    // MARK: - Public methods
    
    public func debug(
        _ message: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        let context = Context(file: file, function: function, line: line)
        handleLog(level: .debug, message: message, context: context)
    }
    
    public func info(
        _ message: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        let context = Context(file: file, function: function, line: line)
        handleLog(level: .info, message: message, context: context)
    }
    
    public func warning(
        _ message: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        let context = Context(file: file, function: function, line: line)
        handleLog(level: .warning, message: message, context: context)
    }
    
    public func error(
        _ message: String,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        let context = Context(file: file, function: function, line: line)
        handleLog(level: .error, message: message, context: context)
    }
    
    // MARK: - Private methods
    
    private func handleLog(level: LogLevel, message: String, context: Context) {
        let message = "\(level.prefix) ➜ \(context.description): \(message)"
        
        #if DEBUG
        logger.log(level: level.osLogType, "\(message)")
        #endif
    }
}
