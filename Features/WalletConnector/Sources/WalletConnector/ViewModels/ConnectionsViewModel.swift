// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
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

    public init(
        service: ConnectionsService
    ) {
        self.service = service
        self.request = ConnectionsRequest()
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
