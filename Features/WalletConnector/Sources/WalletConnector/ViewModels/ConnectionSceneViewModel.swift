// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Localization
import Primitives
import Formatters
import ConnectionsService

public struct ConnectionSceneViewModel: Sendable {
    private static let dateFormatter = RelativeDateFormatter()

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
        Self.dateFormatter.string(from: model.connection.session.createdAt)
    }

    func disconnect() async throws {
        try await service.disconnect(session: model.connection.session)
    }
}

