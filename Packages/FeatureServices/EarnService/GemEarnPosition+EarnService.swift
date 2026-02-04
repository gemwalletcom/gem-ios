// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import GemstonePrimitives
import Primitives

extension EarnPosition {
    public init?(position: GemEarnPosition) {
        guard let assetId = try? Primitives.AssetId(id: position.assetId) else {
            return nil
        }
        self.init(
            assetId: assetId,
            provider: position.provider.map(),
            name: position.name,
            vaultTokenAddress: position.vaultTokenAddress,
            assetTokenAddress: position.assetTokenAddress,
            vaultBalanceValue: position.vaultBalanceValue,
            assetBalanceValue: position.assetBalanceValue,
            balance: position.balance,
            rewards: position.rewards,
            apy: position.apy
        )
    }
}
