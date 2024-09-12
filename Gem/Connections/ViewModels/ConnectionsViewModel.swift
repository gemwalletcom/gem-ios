// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Store

struct ConnectionsViewModel {
    let service: ConnectionsService

    var request: ConnectionsRequest {
        ConnectionsRequest()
    }

    func addConnectionURI(uri: String, wallet: Wallet) async throws {
        try await service.addConnectionURI(uri: uri, wallet: wallet)
    }
}
