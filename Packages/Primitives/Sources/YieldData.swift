// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public enum YieldAction: Codable, Equatable, Hashable, Sendable {
    case deposit
    case withdraw
}

public struct YieldData: Codable, Equatable, Hashable, Sendable {
    public let providerName: String

    public init(providerName: String) {
        self.providerName = providerName
    }
}
