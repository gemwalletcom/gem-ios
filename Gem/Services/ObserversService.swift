// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import DeviceService
import PriceService
import PerpetualService
import WalletConnector
import Primitives

actor ObserversService: Sendable {
    private let connectionsService: ConnectionsService
    private let deviceObserverService: DeviceObserverService
    private let priceObserverService: PriceObserverService
    private let hyperliquidObserverService: any PerpetualObservable<HyperliquidSubscription>

    private var currentWallet: Wallet?

    init(
        connectionsService: ConnectionsService,
        deviceObserverService: DeviceObserverService,
        priceObserverService: PriceObserverService,
        hyperliquidObserverService: any PerpetualObservable<HyperliquidSubscription>
    ) {
        self.connectionsService = connectionsService
        self.deviceObserverService = deviceObserverService
        self.priceObserverService = priceObserverService
        self.hyperliquidObserverService = hyperliquidObserverService
    }

    func setup() async {
        async let walletConnect: () = setupWalletConnect()
        async let device: () = setupDeviceObserver()
        async let observers: () = connectObservers()

        _ = await (walletConnect, device, observers)
    }

    func setupWallet(_ wallet: Wallet) async {
        currentWallet = wallet
        async let assets: () = setupPriceAssets()
        async let perpetual: () = hyperliquidObserverService.connect(for: wallet)
        _ = await (assets, perpetual)
    }

    func handleScenePhase(_ phase: ScenePhase) async {
        switch phase {
        case .active:
            debugLog("ObserversService: App active — connecting observers")
            await connectObservers()
        case .background:
            debugLog("ObserversService: App background — disconnecting observers")
            await disconnectObservers()
        case .inactive:
            debugLog("ObserversService: App inactive")
        @unknown default:
            break
        }
    }
}

// MARK: - Private

extension ObserversService {
    private func setupWalletConnect() async {
        do {
            try await connectionsService.setup()
        } catch {
            debugLog("ObserversService setupWalletConnect error: \(error)")
        }
    }

    private func setupDeviceObserver() async {
        do {
            try await deviceObserverService.startSubscriptionsObserver()
        } catch {
            debugLog("ObserversService setupDeviceObserver error: \(error)")
        }
    }

    private func setupPriceAssets() async {
        do {
            try await priceObserverService.setupAssets()
        } catch {
            debugLog("ObserversService setupPriceAssets error: \(error)")
        }
    }

    private func connectObservers() async {
        let wallet = currentWallet
        async let price: () = priceObserverService.connect()
        async let perpetual: () = {
            if let wallet {
                await hyperliquidObserverService.connect(for: wallet)
            }
        }()
        _ = await (price, perpetual)
    }

    private func disconnectObservers() async {
        async let price: () = priceObserverService.disconnect()
        async let perpetual: () = hyperliquidObserverService.disconnect()
        _ = await (price, perpetual)
    }
}
