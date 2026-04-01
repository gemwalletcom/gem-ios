// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import struct Gemstone.SwapperProviderData
import struct Gemstone.SwapperProviderType
import struct Gemstone.SwapperRoute

public extension SwapperProviderData {
    static func mock(provider: SwapperProviderType = .mock()) -> SwapperProviderData {
        SwapperProviderData(
            provider: provider,
            slippageBps: 50,
            routes: [.mock()]
        )
    }
} 
