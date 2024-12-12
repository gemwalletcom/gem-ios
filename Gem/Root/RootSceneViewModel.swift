// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Keystore
import DeviceService
import Primitives

@Observable
final class RootSceneViewModel {
    let keystore: any Keystore
    let walletConnectorInteractor: WalletConnectorInteractor

    let onstartService: OnstartAsyncService
    let transactionService: TransactionService
    let connectionsService: ConnectionsService
    let deviceObserverService: DeviceObserverService

    var updateAvailableAlertSheetMessage: String?
    var isPresentingConnectorError: String? {
        get { walletConnectorInteractor.isPresentingError }
        set { walletConnectorInteractor.isPresentingError = newValue }
    }
    var isPresentingConnnectorSheet: WalletConnectorSheetType? {
        get { walletConnectorInteractor.isPresentingSheeet }
        set { walletConnectorInteractor.isPresentingSheeet = newValue }
    }

    var isPresentingConnectorBar: Bool {
        get { walletConnectorInteractor.isPresentingConnectionBar }
        set { walletConnectorInteractor.isPresentingConnectionBar = newValue }
    }

    init(resolver: AppResolver) {
        self.keystore = resolver.stores.keystore
        self.walletConnectorInteractor = resolver.services.walletConnectorInteractor
        self.onstartService = resolver.services.onstartService
        self.transactionService = resolver.services.transactionService
        self.connectionsService = resolver.services.connectionsService
        self.deviceObserverService = resolver.services.deviceObserverService
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

    func onWalletChange(_: Wallet?, _ newWallet: Wallet?) {
        if let newWallet {
            onstartService.setup(wallet: newWallet)
        }
    }

    func handleWalletConnectorComplete(type: WalletConnectorSheetType) {
        switch type {
        case .transferData:
            walletConnectorInteractor.isPresentingSheeet = nil
        case .connectionProposal, .signMessage:
            break
        }
    }

    func handleWalletConnectorCancel(type: WalletConnectorSheetType) {
        walletConnectorInteractor.cancel(type: type)
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
