// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import UIKit
import Primitives
import Store
import Localization
import PrimitivesComponents
import Components
import GemstonePrimitives

@Observable
@MainActor
public final class ConnectionsViewModel {
    let service: ConnectionsService
    let walletConnectorPresenter: WalletConnectorPresenter?
    
    var request: ConnectionsRequest
    var connections: [WalletConnection] = []

    var isPresentingScanner: Bool = false
    var isPresentingAlertMessage: AlertMessage?
    var isPresentingConnectorBar: Bool = false

    public init(
        service: ConnectionsService,
        walletConnectorPresenter: WalletConnectorPresenter? = nil
    ) {
        self.service = service
        self.walletConnectorPresenter = walletConnectorPresenter
        self.request = ConnectionsRequest()
    }

    var title: String { Localized.WalletConnect.title }
    var disconnectTitle: String { Localized.WalletConnect.disconnect }
    var pasteButtonTitle: String { Localized.Common.paste }
    var scanQRCodeButtonTitle: String { Localized.Wallet.scanQrCode }
    var docsUrl: URL { Docs.url(.walletConnect) }
    
    
    var sections: [ListSection<WalletConnection>] {
        let grouped = Dictionary(grouping: connections, by: { $0.wallet })
        return grouped.keys
            .sorted { $0.order < $1.order }
            .map { wallet in
                ListSection(
                    id: wallet.id,
                    title: wallet.name,
                    image: nil,
                    values: grouped[wallet]?.sorted { $0.session.createdAt > $1.session.createdAt } ?? []
                )
            }
    }

    var emptyContentModel: EmptyContentTypeViewModel {
        EmptyContentTypeViewModel(type: .walletConnect)
    }

    func connectionSceneModel(connection: WalletConnection) -> ConnectionSceneViewModel {
        ConnectionSceneViewModel(
            model: WalletConnectionViewModel(connection: connection),
            service: service
        )
    }

    func pair(uri: String) async throws {
        try await service.pair(uri: uri)
    }

    func disconnect(connection: WalletConnection) async throws {
        try await service.disconnect(session: connection.session)
    }
    
    func updateSessions() {
        service.updateSessions()
    }
    
    func hideConnectionBar() {
        isPresentingConnectorBar = false
    }
}

// MARK: - Actions

extension ConnectionsViewModel {
    func onScan() {
        isPresentingScanner = true
    }
    
    func onPaste() {
        guard let content = UIPasteboard.general.string else {
            return
        }

        Task {
            await connectURI(uri: content)
        }
    }
    
    func onHandleScan(_ result: String) {
        Task {
            await connectURI(uri: result)
        }
    }
    
    func onSelectDisconnect(_ connection: WalletConnection) {
        Task {
            do {
                try await disconnect(connection: connection)
            } catch {
                isPresentingAlertMessage = AlertMessage(message: error.localizedDescription)
                NSLog("disconnect error: \(error)")
            }
        }
    }
    
    private func connectURI(uri: String) async {
        isPresentingConnectorBar = true
        do {
            try await pair(uri: uri)
        } catch {
            hideConnectionBar()
            isPresentingAlertMessage = AlertMessage(message: error.localizedDescription)
            NSLog("connectURI error: \(error)")
        }
    }
}
