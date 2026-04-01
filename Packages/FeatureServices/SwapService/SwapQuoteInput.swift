// Copyright (c). Gem Wallet. All rights reserved.

import BigInt
import Primitives

public struct SwapQuoteInput: Hashable, Sendable {
    public let fromAsset: Asset
    public let toAsset: Asset
    public let value: BigInt
    public let useMaxAmount: Bool

    public init(fromAsset: Asset, toAsset: Asset, value: BigInt, useMaxAmount: Bool) {
        self.fromAsset = fromAsset
        self.toAsset = toAsset
        self.value = value
        self.useMaxAmount = useMaxAmount
    }
}
