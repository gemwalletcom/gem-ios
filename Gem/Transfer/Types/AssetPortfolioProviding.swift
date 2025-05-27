// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public protocol AssetPortfolioProviding: AnyObject, Sendable {
    func snapshot(
        walletId: WalletId,
        asset: Asset,
        extraIds: [AssetId]
    ) throws -> AssetPortfolio
}
