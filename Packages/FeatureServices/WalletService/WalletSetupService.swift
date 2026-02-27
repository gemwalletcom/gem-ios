// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import BalanceService

public struct WalletSetupService: Sendable {
    private let balanceService: BalanceService

    public init(balanceService: BalanceService) {
        self.balanceService = balanceService
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

        try balanceService.addAssetsBalancesIfMissing(assetIds: chainsEnabledByDefault.ids, wallet: wallet, isEnabled: true)
        try balanceService.addAssetsBalancesIfMissing(assetIds: chainsDisabledByDefault.ids, wallet: wallet, isEnabled: false)

        let defaultAssets = chains.map { $0.defaultAssets.assetIds }.flatMap { $0 }
        try balanceService.addAssetsBalancesIfMissing(assetIds: defaultAssets, wallet: wallet, isEnabled: false)
    }
}
