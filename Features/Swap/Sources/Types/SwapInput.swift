// Copyright (c). Gem Wallet. All rights reserved.

import Primitives

public struct SwapInput: Identifiable {
    public let wallet: Wallet
    public let pairSelector: SwapPairSelectorViewModel

    public init(wallet: Wallet, pairSelector: SwapPairSelectorViewModel) {
        self.wallet = wallet
        self.pairSelector = pairSelector
    }

    public var id: String { "\(wallet.id)\(pairSelector.fromAssetId?.id ?? "")\(pairSelector.toAssetId?.id ?? "")"}
}
