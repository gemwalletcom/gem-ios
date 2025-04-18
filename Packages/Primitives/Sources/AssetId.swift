// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public struct AssetId: Equatable, Hashable, Sendable {
    public let chain: Chain
    public let tokenId: String?

    public init(chain: Chain, tokenId: String?) {
        self.chain = chain
        self.tokenId = tokenId
    }
}

extension AssetId: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let stringValue = try container.decode(String.self)
        let assetId = try AssetId(id: stringValue)
        self = assetId
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(identifier)
    }
}
