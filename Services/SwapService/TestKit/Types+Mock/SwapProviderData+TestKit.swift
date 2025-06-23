// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import struct Gemstone.SwapProviderData
import struct Gemstone.SwapRoute

extension SwapProviderData {
    static func mock() -> SwapProviderData {
        SwapProviderData(
            provider: .mock(),
            slippageBps: 50,
            routes: [.mock()]
        )
    }
} 
