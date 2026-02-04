// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public struct EarnProtocol: Codable, Equatable, Hashable, Sendable {
    public let name: String
    public let assetId: AssetId
    public let provider: EarnProvider
    public let apy: Double?

    public init(name: String, assetId: AssetId, provider: EarnProvider, apy: Double?) {
        self.name = name
        self.assetId = assetId
        self.provider = provider
        self.apy = apy
    }
}
