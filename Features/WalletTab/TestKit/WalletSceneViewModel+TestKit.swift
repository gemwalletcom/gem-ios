// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import WalletTab
import WalletsServiceTestKit
import BalanceServiceTestKit
import BannerServiceTestKit
import WalletServiceTestKit
import PreferencesTestKit
import PrimitivesTestKit

public extension WalletSceneViewModel {
    static func mock() -> WalletSceneViewModel {
        WalletSceneViewModel(
            assetDiscoveryService: .mock(),
            balanceUpdater: .mock(),
            balanceService: .mock(),
            bannerService: .mock(),
            walletService: .mock(),
            observablePreferences: .mock(),
            wallet: .mock(),
            isPresentingSelectedAssetInput: .constant(.none)
        )
    }
}
