// Copyright (c). Gem Wallet. All rights reserved.

import AppService
import Components
import DeviceService
import EventPresenterService
import Foundation
import LockManager
import Localization
import NameService
import Onboarding
import Primitives
import SwiftUI
import TransactionStateService
import TransactionsService
import WalletConnector
import WalletService
import WalletsService
import AvatarService

@Observable
@MainActor
final class RootSceneViewModel {
    private let onstartWalletService: OnstartWalletService
    private let transactionStateService: TransactionStateService
    private let connectionsService: ConnectionsService
    private let deviceObserverService: DeviceObserverService
    private let navigationHandler: NavigationHandler
    private let walletsService: WalletsService
    private let releaseAlertService: ReleaseAlertService
    private let rateService: RateService
    private let eventPresenterService: EventPresenterService
    private let deviceService: DeviceService

    let walletService: WalletService
    let nameService: NameService
    let avatarService: AvatarService
    let walletConnectorPresenter: WalletConnectorPresenter
    let lockManager: any LockWindowManageable
    var currentWallet: Wallet? { walletService.currentWallet }

    var updateVersionAlertMessage: AlertMessage?

    var isPresentingToastMessage: ToastMessage? {
        get { eventPresenterService.toastPresenter.toastMessage }
        set { eventPresenterService.toastPresenter.toastMessage = newValue }
    }

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

    var toastOffset: CGFloat {
        UIDevice.current.userInterfaceIdiom == .phone ? .space32 + .space16 : .zero
    }

    init(
        walletConnectorPresenter: WalletConnectorPresenter,
        onstartWalletService: OnstartWalletService,
        transactionStateService: TransactionStateService,
        connectionsService: ConnectionsService,
        deviceObserverService: DeviceObserverService,
        navigationHandler: NavigationHandler,
        lockWindowManager: any LockWindowManageable,
        walletService: WalletService,
        walletsService: WalletsService,
        nameService: NameService,
        releaseAlertService: ReleaseAlertService,
        rateService: RateService,
        eventPresenterService: EventPresenterService,
        avatarService: AvatarService,
        deviceService: DeviceService
    ) {
        self.walletConnectorPresenter = walletConnectorPresenter
        self.onstartWalletService = onstartWalletService
        self.transactionStateService = transactionStateService
        self.connectionsService = connectionsService
        self.deviceObserverService = deviceObserverService
        self.navigationHandler = navigationHandler
        self.lockManager = lockWindowManager
        self.walletService = walletService
        self.walletsService = walletsService
        self.nameService = nameService
        self.releaseAlertService = releaseAlertService
        self.rateService = rateService
        self.eventPresenterService = eventPresenterService
        self.avatarService = avatarService
        self.deviceService = deviceService
    }
}

// MARK: - Business Logic

extension RootSceneViewModel {
    func setup() {
        rateService.perform()
        Task { await checkForUpdate() }
        Task { try await deviceService.update() }
        transactionStateService.setup()
        Task { try await connectionsService.setup() }
        Task { try await deviceObserverService.startSubscriptionsObserver() }
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
            let action = try URLParser.from(url: url)
            switch action {
            case .walletConnect(let walletConnectAction):
                try await handleWalletConnect(walletConnectAction)
            case .asset, .swap, .perpetuals, .rewards, .gift, .buy, .sell, .setPriceAlert:
                await navigationHandler.handle(action)
            }
        } catch {
            debugLog("RootSceneViewModel handleUrl error: \(error)")
            isPresentingConnectorError = error.localizedDescription
        }
    }
}

// MARK: - Private

extension RootSceneViewModel {
    private func setup(wallet: Wallet) {
        navigationHandler.wallet = wallet
        onstartWalletService.setup(wallet: wallet)
        do {
            try walletsService.setup(wallet: wallet)
        } catch {
            debugLog("RootSceneViewModel setupWallet error: \(error)")
        }
    }

    private func checkForUpdate() async {
        guard let release = await releaseAlertService.checkForUpdate() else { return }
        updateVersionAlertMessage = makeUpdateAlert(for: release)
    }

    private func makeUpdateAlert(for release: Release) -> AlertMessage {
        let skipAction = AlertAction(
            title: Localized.Common.skip,
            role: .cancel,
            action: { [releaseAlertService] in
                releaseAlertService.skipRelease(release)
            }
        )
        let updateAction = AlertAction(
            title: Localized.UpdateApp.action,
            isDefaultAction: true,
            action: { [releaseAlertService] in
                Task { @MainActor in
                    releaseAlertService.openAppStore()
                }
            }
        )
        let actions = release.upgradeRequired ? [updateAction] : [skipAction, updateAction]

        return AlertMessage(
            title: Localized.UpdateApp.title,
            message: Localized.UpdateApp.description(release.version),
            actions: actions
        )
    }

    private func handleWalletConnect(_ action: WalletConnectAction) async throws {
        isPresentingConnectorBar = true
        switch action {
        case .connect(let uri):
            try await connectionsService.pair(uri: uri)
        case .request:
            break
        case .session:
            connectionsService.updateSessions()
        }
    }
}
