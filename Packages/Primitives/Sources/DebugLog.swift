// Copyright (c). Gem Wallet. All rights reserved.

@_exported import Logger

@available(*, deprecated, message: "Use #debugLog macro instead")
public func debugLog(_ message: @autoclosure () -> String) {
    DebugLoggerRuntime.emit(
        message(),
        fileID: #fileID,
        function: #function,
        line: #line
    )
}
