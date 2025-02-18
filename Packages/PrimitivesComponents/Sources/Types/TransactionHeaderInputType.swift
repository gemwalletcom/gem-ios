// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import BigInt

public enum TransacitonHeaderInputType: Sendable {
    public struct SwapMetadata: Sendable {
        let fromAsset: Asset
        let fromValue: BigInt
        let fromPrice: Price?

        let toAsset: Asset
        let toValue: BigInt
        let toPrice: Price?

        public init(fromAsset: Asset, fromValue: BigInt, fromPrice: Price?, toAsset: Asset, toValue: BigInt, toPrice: Price?) {
            self.fromAsset = fromAsset
            self.fromValue = fromValue
            self.fromPrice = fromPrice
            self.toAsset = toAsset
            self.toValue = toValue
            self.toPrice = toPrice
        }
    }

    case amount(showFiatSubtitle: Bool)
    case nft(NFTAsset)
    case swap(SwapMetadata)
}
