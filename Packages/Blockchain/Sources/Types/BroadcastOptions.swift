// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public struct BroadcastOptions: Sendable {
    public let skipPreflight: Bool
    
    public init(skipPreflight: Bool) {
        self.skipPreflight = skipPreflight
    }
    
    public static let standard = BroadcastOptions(skipPreflight: false)
}
