// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Gemstone
import Primitives
import Store

extension YieldPositionRecord {
    init?(walletId: WalletId, position: GemYieldPosition) {
        guard let assetId = try? Primitives.AssetId(id: position.assetId) else {
            return nil
        }
        let uniqueId = "\(walletId.id)_\(position.assetId)_\(position.provider.name)"
        self.init(
            id: uniqueId,
            walletId: walletId.id,
            assetId: assetId,
            provider: position.provider.name,
            name: position.name,
            vaultTokenAddress: position.vaultTokenAddress,
            assetTokenAddress: position.assetTokenAddress,
            vaultBalanceValue: position.vaultBalanceValue,
            assetBalanceValue: position.assetBalanceValue,
            apy: position.apy,
            rewards: position.rewards
        )
    }

    func toGemYieldPosition() -> GemYieldPosition {
        GemYieldPosition(
            name: name,
            assetId: assetId.identifier,
            provider: GemYieldProvider(name: provider),
            vaultTokenAddress: vaultTokenAddress,
            assetTokenAddress: assetTokenAddress,
            vaultBalanceValue: vaultBalanceValue,
            assetBalanceValue: assetBalanceValue,
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
