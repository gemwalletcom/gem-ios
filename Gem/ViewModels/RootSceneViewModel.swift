// Copyright (c). Gem Wallet. All rights reserved.

import AppService
import Components
import DeviceService
import Foundation
import GemstonePrimitives
import LockManager
import Localization
import Onboarding
import Primitives
import SwiftUI
import TransactionStateService
import TransactionsService
import WalletConnector
import WalletService
import WalletsService
import NameService

@Observable
@MainActor
final class RootSceneViewModel {
    private let onstartAsyncService: OnstartAsyncService
    private let onstartWalletService: OnstartWalletService
    private let transactionStateService: TransactionStateService
    private let connectionsService: ConnectionsService
    private let deviceObserverService: DeviceObserverService
    private let notificationHandler: NotificationHandler
    private let walletsService: WalletsService

    let walletService: WalletService
    let nameService: NameService
    let walletConnectorPresenter: WalletConnectorPresenter
    let lockManager: any LockWindowManageable
    var currentWallet: Wallet? { walletService.currentWallet }

    var updateVersionAlertMessage: AlertMessage?

    var isPresentingConnectorError: String? {
        get { walletConnectorPresenter.isPresentingError }
        set { walletConnectorPresenter.isPresentingError = newValue }
    }

    var isPresentingConnnectorSheet: WalletConnectorSheetType? {
        get { walletConnectorPresenter.isPresentingSheet }
        set { walletConnectorPresenter.isPresentingSheet = newValue }
    }

    var isPresentingConnectorBar: Bool {
        get { walletConnectorPresenter.isPresentingConnectionBar }
        set { walletConnectorPresenter.isPresentingConnectionBar = newValue }
    }

    init(
        walletConnectorPresenter: WalletConnectorPresenter,
        onstartAsyncService: OnstartAsyncService,
        onstartWalletService: OnstartWalletService,
        transactionStateService: TransactionStateService,
        connectionsService: ConnectionsService,
        deviceObserverService: DeviceObserverService,
        notificationHandler: NotificationHandler,
        lockWindowManager: any LockWindowManageable,
        walletService: WalletService,
        walletsService: WalletsService,
        nameService: NameService
    ) {
        self.walletConnectorPresenter = walletConnectorPresenter
        self.onstartAsyncService = onstartAsyncService
        self.onstartWalletService = onstartWalletService
        self.transactionStateService = transactionStateService
        self.connectionsService = connectionsService
        self.deviceObserverService = deviceObserverService
        self.notificationHandler = notificationHandler
        self.lockManager = lockWindowManager
        self.walletService = walletService
        self.walletsService = walletsService
        self.nameService = nameService
    }
}

// MARK: - Business Logic

extension RootSceneViewModel {
    func setup() {
        onstartAsyncService.releaseAction = { [weak self] in
            self?.setupUpdateReleaseAlert($0)
        }
        onstartAsyncService.setup()
        transactionStateService.setup()
        Task {
            try await connectionsService.setup()
        }
        Task {
            try await deviceObserverService.startSubscriptionsObserver()
        }
    }
}

// MARK: - Effects

extension RootSceneViewModel {
    func onChangeWallet(_ oldWallet: Wallet?, _ newWallet: Wallet?) {
        if let newWallet {
            setup(wallet: newWallet)
        }
    }

    func handleOpenUrl(_ url: URL) async {
        do {
            let parsedURL = try URLParser.from(url: url)
            switch parsedURL {
            case .walletConnect(let uri):
                isPresentingConnectorBar = true
                try await connectionsService.pair(uri: uri)
            case .walletConnectRequest:
                isPresentingConnectorBar = true
            case .walletConnectSession:
                isPresentingConnectorBar = true
                connectionsService.updateSessions()
            case .asset(let assetId):
                notificationHandler.notify(notification: PushNotification.asset(assetId))
            case let .swap(fromAssetId, toAssetId):
                notificationHandler.notify(notification: PushNotification.swapAsset(fromAssetId, toAssetId))
            case .perpetuals:
                notificationHandler.notify(notification: PushNotification.perpetuals)
            case .rewards(let code):
                notificationHandler.notify(notification: PushNotification.referral(code: code))
            case let .buy(assetId, amount):
                notificationHandler.notify(notification: PushNotification.buyAsset(assetId, amount: amount))
            case let .sell(assetId, amount):
                notificationHandler.notify(notification: PushNotification.sellAsset(assetId, amount: amount))
            case let .setPriceAlert(assetId, price):
                notificationHandler.notify(notification: PushNotification.setPriceAlert(assetId, price: price))
            case .none:
                break
            }
        } catch {
            debugLog("RootSceneViewModel handleUrl error: \(error)")
            isPresentingConnectorError = error.localizedDescription
        }
    }
    
    private func setupUpdateReleaseAlert(_ release: Release) {
        let skipAction = AlertAction(
            title: Localized.Common.skip,
            role: .cancel,
            action: { [weak self] in
                Task { @MainActor in
                    self?.onstartAsyncService.skipRelease(release.version)
                }
            }
        )
        let updateAction = AlertAction(
            title: Localized.UpdateApp.action,
            isDefaultAction: true,
            action: {
                Task { @MainActor in
                    UIApplication.shared.open(PublicConstants.url(.appStore))
                }
            }
        )
        let actions = if release.upgradeRequired {
            [updateAction]
        } else {
            [skipAction, updateAction]
        }
        
        updateVersionAlertMessage = AlertMessage(
            title: Localized.UpdateApp.title,
            message: Localized.UpdateApp.description(release.version),
            actions: actions
        )
    }
}

// MARK: - Private

extension RootSceneViewModel {
    private func setup(wallet: Wallet) {
        onstartWalletService.setup(wallet: wallet)
        do {
            try walletsService.setup(wallet: wallet)
        } catch {
            debugLog("RootSceneViewModel setupWallet error: \(error)")
        }
    }
}
