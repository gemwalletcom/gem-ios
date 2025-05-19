// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import DeviceService
import Primitives
import SwiftUI
import LockManager
import WalletConnector
import TransactionsService
import TransactionService
import WalletService
import WalletsService
import Onboarding

@Observable
@MainActor
final class RootSceneViewModel {
    private let onstartService: OnstartAsyncService
    private let transactionService: TransactionService
    private let connectionsService: ConnectionsService
    private let deviceObserverService: DeviceObserverService
    private let notificationService: NotificationService
    private let walletsService: WalletsService

    let walletService: WalletService
    let walletConnectorPresenter: WalletConnectorPresenter
    let lockManager: any LockWindowManageable
    var currentWallet: Wallet? { walletService.currentWallet }

    var availableRelease: Release?
    var canSkipUpdate: Bool { availableRelease?.upgradeRequired == false }
    
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
        onstartService: OnstartAsyncService,
        transactionService: TransactionService,
        connectionsService: ConnectionsService,
        deviceObserverService: DeviceObserverService,
        notificationService: NotificationService,
        lockWindowManager: any LockWindowManageable,
        walletService: WalletService,
        walletsService: WalletsService
    ) {
        self.walletConnectorPresenter = walletConnectorPresenter
        self.onstartService = onstartService
        self.transactionService = transactionService
        self.connectionsService = connectionsService
        self.deviceObserverService = deviceObserverService
        self.notificationService = notificationService
        self.lockManager = lockWindowManager
        self.walletService = walletService
        self.walletsService = walletsService
    }
}

// MARK: - Business Logic

extension RootSceneViewModel {
    func setup() {
        onstartService.releaseAction = { [weak self] in
            guard let self else { return }
            self.availableRelease = $0
        }
        onstartService.setup()
        transactionService.setup()
        connectionsService.setup()
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
            case .asset(let assetId):
                notificationService.notify(notification: PushNotification.asset(assetId))
            }
        } catch {
            NSLog("RootSceneViewModel handleUrl error: \(error)")
            isPresentingConnectorError = error.localizedDescription
        }
    }
    
    func skipRelease() {
        guard let version = availableRelease?.version else { return }
        onstartService.skipRelease(version)
    }
}

// MARK: - Private

extension RootSceneViewModel {

    private func setup(wallet: Wallet) {
        onstartService.setup(wallet: wallet)
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
