// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import Primitives

extension EarnPosition {
    public init?(walletId: WalletId, position: GemYieldPosition) {
        guard let assetId = try? Primitives.AssetId(id: position.assetId) else {
            return nil
        }
        self.init(
            walletId: walletId.id,
            assetId: assetId,
            type: .yield(YieldPositionData(
                provider: position.provider.name,
                name: position.name,
                vaultTokenAddress: position.vaultTokenAddress,
                assetTokenAddress: position.assetTokenAddress,
                vaultBalanceValue: position.vaultBalanceValue,
                assetBalanceValue: position.assetBalanceValue
            )),
            balance: position.assetBalanceValue ?? "0",
            rewards: position.rewards,
            apy: position.apy
        )
    }
}
