// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import struct Gemstone.SwapperProviderData
import struct Gemstone.SwapperRoute

extension SwapperProviderData {
    static func mock() -> SwapperProviderData {
        SwapperProviderData(
            provider: .mock(),
            slippageBps: 50,
            routes: [.mock()]
        )
    }
} 
