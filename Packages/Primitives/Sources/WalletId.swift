// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public struct WalletId: Codable, Equatable, Hashable, Sendable {
    public let id: String

    public init(id: String) {
        self.id = id
    }
}
