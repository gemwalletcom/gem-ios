// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Store
import Localization
import PrimitivesComponents
@preconcurrency import Keystore

public struct ConnectionsViewModel: Sendable {
    let service: ConnectionsService
    let keystore: any Keystore

    public init(service: ConnectionsService,
         keystore: any Keystore) {
        self.service = service
        self.keystore = keystore
    }

    var title: String { Localized.WalletConnect.title }

    var pasteButtonTitle: String { Localized.Common.paste }
    var scanQRCodeButtonTitle: String { Localized.Wallet.scanQrCode }

    var request: ConnectionsRequest { ConnectionsRequest() }

    var emptyContentModel: EmptyContentTypeViewModel {
        EmptyContentTypeViewModel(type: .walletConnect)
    }

    func addConnectionURI(uri: String) async throws {
        let wallet = try keystore.getCurrentWallet()
        try await service.addConnectionURI(uri: uri, wallet: wallet)
    }
}
