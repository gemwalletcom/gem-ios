// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Keystore
import DeviceService
import Primitives
import SwiftUI
import LockManager
import WalletConnector

@Observable
@MainActor
final class RootSceneViewModel {
    let keystore: any Keystore
    private let onstartService: OnstartAsyncService
    private let transactionService: TransactionService
    private let connectionsService: ConnectionsService
    private let deviceObserverService: DeviceObserverService

    let walletConnectorPresenter: WalletConnectorPresenter
    let lockManager: any LockWindowManageable

    var currentWallet: Wallet? { keystore.currentWallet }
    var updateAvailableAlertSheetMessage: String?
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

    init(keystore: any Keystore,
         walletConnectorPresenter: WalletConnectorPresenter,
         onstartService: OnstartAsyncService,
         transactionService: TransactionService,
         connectionsService: ConnectionsService,
         deviceObserverService: DeviceObserverService,
         lockWindowManager: any LockWindowManageable
    ) {
        self.keystore = keystore
        self.walletConnectorPresenter = walletConnectorPresenter
        self.onstartService = onstartService
        self.transactionService = transactionService
        self.connectionsService = connectionsService
        self.deviceObserverService = deviceObserverService
        self.lockManager = lockWindowManager
    }
}

// MARK: - Business Logic

extension RootSceneViewModel {
    func setup() {
        onstartService.updateVersionAction = { [self] in
            self.updateAvailableAlertSheetMessage = $0
        }
        onstartService.setup()
        transactionService.setup()
        connectionsService.setup()
        deviceObserverService.startSubscriptionsObserver()

        if let wallet = keystore.currentWallet {
            onstartService.setup(wallet: wallet)
        }
    }
}

// MARK: - Effects

extension RootSceneViewModel {
    func onWalletChange(_: Wallet?, _ newWallet: Wallet?) {
        if let newWallet {
            onstartService.setup(wallet: newWallet)
        }
    }

    func handleOpenUrl(_ url: URL) async {
        do {
            let parsedURL = try URLParser.from(url: url)
            switch parsedURL {
            case .walletConnect(let uri):
                isPresentingConnectorBar = true
                try await connectionsService.addConnectionURI(
                    uri: uri,
                    wallet: try keystore.getCurrentWallet()
                )
            case .walletConnectRequest:
                isPresentingConnectorBar = true
            }
        } catch {
            NSLog("handleUrl error: \(error)")
            isPresentingConnectorError = error.localizedDescription
        }
    }
}
