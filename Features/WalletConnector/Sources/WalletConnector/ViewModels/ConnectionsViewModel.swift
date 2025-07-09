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
    
    var request: ConnectionsRequest
    var connections: [WalletConnection] = []
    var isPresentingScanner: Bool = false
    var isPresentingAlertMessage: AlertMessage?

    public init(
        service: ConnectionsService
    ) {
        self.service = service
        self.request = ConnectionsRequest()
        self.isPresentingScanner = false
        self.isPresentingAlertMessage = nil
    }

    var title: String { Localized.WalletConnect.title }
    var disconnectTitle: String { Localized.WalletConnect.disconnect }
    var pasteButtonTitle: String { Localized.Common.paste }
    var scanQRCodeButtonTitle: String { Localized.Wallet.scanQrCode }
    var docsUrl: URL { Docs.url(.walletConnect) }
    
    var sections: [ListSection<WalletConnection>] {
        Dictionary(grouping: connections, by: { $0.wallet }).map { wallet, connections in
            ListSection(
                id: wallet.id,
                title: wallet.name,
                image: nil,
                values: connections
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
        do {
            try await pair(uri: uri)
        } catch {
            isPresentingAlertMessage = AlertMessage(message: error.localizedDescription)
            NSLog("connectURI error: \(error)")
        }
    }
}
