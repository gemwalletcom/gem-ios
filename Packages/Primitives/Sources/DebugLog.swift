// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

/// Prints debug information only in DEBUG builds to avoid leaking data in production logs.
/// Uses NSLog for consistency with system logging.
@inlinable
public func debugLog(_ message: @autoclosure () -> String) {
    #if DEBUG
        NSLog("%@", message())
    #endif
}
