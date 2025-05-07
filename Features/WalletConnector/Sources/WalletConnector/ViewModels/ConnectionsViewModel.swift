// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Store
import Localization
import PrimitivesComponents

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
    
    var groupedByWallet: [Wallet: [Primitives.WalletConnection]] {
        Dictionary(grouping: connections, by: { $0.wallet })
    }
    
    var headers: [Wallet] {
        groupedByWallet.map({ $0.key }).sorted { $0.order < $1.order }
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
