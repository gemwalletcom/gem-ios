// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import Primitives

extension GemEarnPosition {
    public func map() throws -> EarnPosition {
        EarnPosition(
            assetId: try AssetId(id: assetId),
            provider: provider.map(),
            vaultTokenAddress: vaultTokenAddress,
            assetTokenAddress: assetTokenAddress,
            vaultBalanceValue: vaultBalanceValue,
            assetBalanceValue: assetBalanceValue,
            balance: balance,
            rewards: rewards,
            apy: apy
        )
    }
}

extension EarnPosition {
    public func map() -> GemEarnPosition {
        GemEarnPosition(
            assetId: assetId.identifier,
            provider: provider.map(),
            vaultTokenAddress: vaultTokenAddress,
            assetTokenAddress: assetTokenAddress,
            vaultBalanceValue: vaultBalanceValue,
            assetBalanceValue: assetBalanceValue,
            balance: balance,
            apy: apy,
            rewards: rewards
        )
    }
}
