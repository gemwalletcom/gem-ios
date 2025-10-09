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
import Preferences
import PreferencesTestKit
import DeviceService
import DeviceServiceTestKit

public extension WalletsService {
    static func mock(
        walletStore: WalletStore = .mock(),
        assetsService: AssetsService = .mock(),
        balanceService: BalanceService = .mock(),
        priceService: PriceService = .mock(),
        priceObserver: PriceObserverService = .mock(),
        preferences: ObservablePreferences = .mock(),
        deviceService: DeviceService = .mock()
    ) -> WalletsService {
        WalletsService(
            walletStore: walletStore,
            assetsService: assetsService,
            balanceService: balanceService,
            priceService: priceService,
            priceObserver: priceObserver,
            preferences: preferences,
            deviceService: deviceService
        )
    }
}
