// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

struct ConnectionsViewModel {
    let service: ConnectionsService
    
    func addConnectionURI(uri: String, wallet: Wallet) async throws {
        try await service.addConnectionURI(uri: uri, wallet: wallet)
    }
}
