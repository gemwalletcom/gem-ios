// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Primitives
import PrimitivesTestKit
import Preferences
import PreferencesTestKit
import PerpetualService
import PerpetualServiceTestKit
@testable import AppService

struct AppLifecycleServiceTests {

    @Test
    func setupWalletConnectsHyperliquidForMultiCoinWallet() async {
        let (service, observer, _) = makeService(perpetualEnabled: true)

        await service.setupWallet(.mock(type: .multicoin))

        #expect(await observer.isConnected == true)
    }

    @Test
    func setupWalletSkipsHyperliquidForSingleChainWallet() async {
        let (service, observer, _) = makeService(perpetualEnabled: true)

        await service.setupWallet(.mock(type: .single))

        #expect(await observer.isConnected == false)
    }

    @Test
    func setupWalletDisconnectsWhenSwitchingToSingleChainWallet() async {
        let (service, observer, _) = makeService(perpetualEnabled: true)
        await service.setupWallet(.mock(type: .multicoin))

        await service.setupWallet(.mock(type: .single))

        #expect(await observer.isConnected == false)
    }

    @Test
    func setupWalletSkipsHyperliquidWhenDisabled() async {
        let (service, observer, _) = makeService(perpetualEnabled: false)

        await service.setupWallet(.mock(type: .multicoin))

        #expect(await observer.isConnected == false)
    }

    @Test
    func updatePerpetualConnectionDisconnectsWhenDisabled() async {
        let (service, observer, preferences) = makeService(perpetualEnabled: true)
        await service.setupWallet(.mock(type: .multicoin))

        preferences.isPerpetualEnabled = false
        await service.updatePerpetualConnection()

        #expect(await observer.isConnected == false)
    }

    @Test
    func updatePerpetualConnectionSkipsForSingleChainWallet() async {
        let (service, observer, _) = makeService(perpetualEnabled: true)
        await service.setupWallet(.mock(type: .single))

        await service.updatePerpetualConnection()

        #expect(await observer.isConnected == false)
    }
}

extension AppLifecycleServiceTests {
    func makeService(perpetualEnabled: Bool) -> (AppLifecycleService, PerpetualObserverMock, Preferences) {
        let preferences = Preferences.mock()
        preferences.isPerpetualEnabled = perpetualEnabled
        let observer = PerpetualObserverMock()
        let service = AppLifecycleService.mock(preferences: preferences, hyperliquidObserverService: observer)
        return (service, observer, preferences)
    }
}
