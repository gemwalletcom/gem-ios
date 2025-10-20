// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import struct Gemstone.GemSwapProviderData
import Primitives

public extension Gemstone.GemSwapProviderData {
    func map() throws -> Primitives.SwapProviderData {
        return Primitives.SwapProviderData(
            provider: provider.asPrimitives(),
            name: name,
            protocolName: protocolName
        )
    }
}

extension Primitives.SwapProviderData {
    func map() -> Gemstone.GemSwapProviderData {
        Gemstone.GemSwapProviderData(
            provider: provider.map(),
            name: name,
            protocolName: protocolName
        )
    }
}
