// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import Primitives
import Store

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

    public func toGemYieldPosition() -> GemYieldPosition? {
        guard let yieldData = type.yieldData else { return nil }
        return GemYieldPosition(
            name: yieldData.name,
            assetId: assetId.identifier,
            provider: GemYieldProvider(name: yieldData.provider),
            vaultTokenAddress: yieldData.vaultTokenAddress ?? "",
            assetTokenAddress: yieldData.assetTokenAddress ?? "",
            vaultBalanceValue: yieldData.vaultBalanceValue,
            assetBalanceValue: yieldData.assetBalanceValue,
            apy: apy,
            rewards: rewards
        )
    }
}

extension GemYieldProvider {
    init(name: String) {
        switch name {
        case "yo": self = .yo
        default: self = .yo
        }
    }
}
