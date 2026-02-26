// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import WalletTab
import WalletsServiceTestKit
import BalanceServiceTestKit
import BannerServiceTestKit
import WalletServiceTestKit
import PreferencesTestKit
import PrimitivesTestKit

public extension WalletSceneViewModel {
    static func mock(wallet: Wallet = .mock()) -> WalletSceneViewModel {
        WalletSceneViewModel(
            assetDiscoveryService: .mock(),
            balanceUpdater: .mock(),
            balanceService: .mock(),
            bannerService: .mock(),
            walletService: .mock(),
            observablePreferences: .mock(),
            wallet: wallet,
            isPresentingSelectedAssetInput: .constant(.none)
        )
    }
}
