// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Store
import Localization

struct ConnectionsViewModel {
    let service: ConnectionsService

    var title: String { Localized.WalletConnect.title }

    var pasteButtonTitle: String { Localized.Common.paste }
    var scanQRCodeButtonTitle: String { Localized.Wallet.scanQrCode }
    var emptyStateTitle: String { Localized.WalletConnect.noActiveConnections }

    var request: ConnectionsRequest {
        ConnectionsRequest()
    }

    func addConnectionURI(uri: String, wallet: Wallet) async throws {
        try await service.addConnectionURI(uri: uri, wallet: wallet)
    }
}
