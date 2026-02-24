// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public struct WalletSetupService: Sendable {
    private let balanceUpdater: any BalanceUpdater

    public init(balanceUpdater: any BalanceUpdater) {
        self.balanceUpdater = balanceUpdater
    }

    public func setup(wallet: Wallet) throws {
        let chains = wallet.chains

        let (chainsEnabledByDefault, chainsDisabledByDefault) = chains.reduce(into: ([Chain](), [Chain]())) { result, chain in
            if AssetConfiguration.enabledByDefault.contains(chain.assetId) || (wallet.accounts.count == 1 && chains.count == 1) {
                result.0.append(chain)
            } else {
                result.1.append(chain)
            }
        }

        try balanceUpdater.addBalancesIfMissing(for: wallet.walletId, assetIds: chainsEnabledByDefault.ids, isEnabled: true)
        try balanceUpdater.addBalancesIfMissing(for: wallet.walletId, assetIds: chainsDisabledByDefault.ids, isEnabled: false)

        let defaultAssets = chains.map { $0.defaultAssets.assetIds }.flatMap { $0 }
        try balanceUpdater.addBalancesIfMissing(for: wallet.walletId, assetIds: defaultAssets, isEnabled: false)
    }
}
