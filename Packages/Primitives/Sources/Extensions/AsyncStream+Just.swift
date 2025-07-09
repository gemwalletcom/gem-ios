// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public extension AsyncStream {
    static func just(_ value: Element) -> AsyncStream<Element> where Element: Sendable {
        AsyncStream { continuation in
            continuation.yield(value)
            continuation.finish()
        }
    }
}
