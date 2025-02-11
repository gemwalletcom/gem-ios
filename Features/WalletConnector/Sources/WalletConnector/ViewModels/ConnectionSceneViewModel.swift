// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Localization
import Primitives

public struct ConnectionSceneViewModel: Sendable {
    let model: WalletConnectionViewModel
    let service: ConnectionsService
    
    var title: String {
        Localized.WalletConnect.Connection.title
    }
    var disconnectTitle: String { Localized.WalletConnect.disconnect }

    var walletField: String { Localized.Common.wallet }
    var walletText: String { model.connection.wallet.name }
    
    var dateField: String { Localized.Transaction.date }
    var dateText: String {
        ConnectionDateFormatter(date: model.connection.session.createdAt).dateString
    }

    func disconnect() async throws {
        let sessionId = model.connection.session.sessionId
        let pairingId = model.connection.session.id
        if sessionId == pairingId {
            try await service.disconnectPairing(pairingId: pairingId)
        } else {
            try await service.disconnect(sessionId: sessionId)
            try await service.disconnectPairing(pairingId: pairingId)
        }
    }
}
