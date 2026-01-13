// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public struct YieldInput: Sendable {
    public let wallet: Wallet
    public let asset: Asset

    public init(wallet: Wallet, asset: Asset) {
        self.wallet = wallet
        self.asset = asset
    }
}
