// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import WalletsService
import Store
import StoreTestKit
import AssetsService
import AssetsServiceTestKit
import BalanceService
import BalanceServiceTestKit
import PriceService
import PriceServiceTestKit
import DeviceService
import DeviceServiceTestKit
import DiscoverAssetsService
import DiscoverAssetsServiceTestKit
import PreferencesTestKit
import WalletSessionService
import WalletSessionServiceTestKit

public extension WalletsService {
    static func mock(
        walletSessionService: WalletSessionService = WalletSessionService(walletStore: .mock(), preferences: .mock()),
        assetsService: AssetsService = .mock(),
        balanceService: BalanceService = .mock(),
        priceService: PriceService = .mock(),
        priceObserver: PriceObserverService = .mock(),
        deviceService: DeviceService = .mock(),
        discoverAssetsService: DiscoverAssetsService = .mock()
    ) -> WalletsService {
        WalletsService(
            walletSessionService: walletSessionService,
            assetsService: assetsService,
            balanceService: balanceService,
            priceService: priceService,
            priceObserver: priceObserver,
            deviceService: deviceService,
            discoverAssetsService: discoverAssetsService
        )
    }
}
