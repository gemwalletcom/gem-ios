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
import TransactionService
import TransactionsService
import WalletConnector
import WalletService
import WalletsService

@Observable
@MainActor
final class RootSceneViewModel {
    private let onstartAsyncService: OnstartAsyncService
    private let transactionService: TransactionService
    private let connectionsService: ConnectionsService
    private let deviceObserverService: DeviceObserverService
    private let notificationHandler: NotificationHandler
    private let walletsService: WalletsService

    let walletService: WalletService
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
        transactionService: TransactionService,
        connectionsService: ConnectionsService,
        deviceObserverService: DeviceObserverService,
        notificationHandler: NotificationHandler,
        lockWindowManager: any LockWindowManageable,
        walletService: WalletService,
        walletsService: WalletsService
    ) {
        self.walletConnectorPresenter = walletConnectorPresenter
        self.onstartAsyncService = onstartAsyncService
        self.transactionService = transactionService
        self.connectionsService = connectionsService
        self.deviceObserverService = deviceObserverService
        self.notificationHandler = notificationHandler
        self.lockManager = lockWindowManager
        self.walletService = walletService
        self.walletsService = walletsService
    }
}

// MARK: - Business Logic

extension RootSceneViewModel {
    func setup() {
        onstartAsyncService.releaseAction = { [weak self] in
            self?.setupUpdateReleaseAlert($0)
        }
        onstartAsyncService.setup()
        transactionService.setup()
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
            }
        } catch {
            NSLog("RootSceneViewModel handleUrl error: \(error)")
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
        onstartAsyncService.setup(wallet: wallet)
        do {
            try walletsService.setup(wallet: wallet)
        } catch {
            NSLog("RootSceneViewModel setupWallet error: \(error)")
        }
        Task {
            await walletsService.runAddressStatusCheck(wallet)
        }
    }
}
