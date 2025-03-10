// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Store
import Localization

public struct ConnectionsViewModel: Sendable {
    let service: ConnectionsService

    public init(
        service: ConnectionsService
    ) {
        self.service = service
    }

    var title: String { Localized.WalletConnect.title }
    var disconnectTitle: String { Localized.WalletConnect.disconnect }
    var pasteButtonTitle: String { Localized.Common.paste }
    var scanQRCodeButtonTitle: String { Localized.Wallet.scanQrCode }
    var emptyStateTitle: String { Localized.WalletConnect.noActiveConnections }

    var request: ConnectionsRequest { ConnectionsRequest() }

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
}
