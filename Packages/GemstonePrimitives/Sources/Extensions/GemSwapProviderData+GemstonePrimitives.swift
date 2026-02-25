// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import struct Gemstone.GemSwapProviderData
import Primitives

public extension Gemstone.GemSwapProviderData {
    func map() throws -> Primitives.SwapProviderData {
        Primitives.SwapProviderData(
            provider: try provider.map(),
            name: name,
            protocolName: protocolName
        )
    }
}

extension Primitives.SwapProviderData {
    func map() throws -> Gemstone.GemSwapProviderData {
        Gemstone.GemSwapProviderData(
            provider: try provider.map(),
            name: name,
            protocolName: protocolName
        )
    }
}
