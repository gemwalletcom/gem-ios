// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import WalletTab
import WalletsServiceTestKit
import BannerServiceTestKit
import WalletServiceTestKit
import PreferencesTestKit
import PrimitivesTestKit

public extension WalletSceneViewModel {
    static func mock() -> WalletSceneViewModel {
        WalletSceneViewModel(
            walletsService: .mock(),
            bannerService: .mock(),
            walletService: .mock(),
            observablePreferences: .mock(),
            wallet: .mock(),
            isPresentingSelectedAssetInput: .constant(.none),
            isPresentingConfirmTransfer: .constant(.none)
        )
    }
}
