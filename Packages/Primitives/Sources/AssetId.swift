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
    enum CodingKeys: String, CodingKey {
        case chain
        case tokenId
    }
    
    public init(from decoder: Decoder) throws {
        if let container = try? decoder.singleValueContainer(), let stringValue = try? container.decode(String.self) {
            let assetId = try AssetId(id: stringValue)
            self = assetId
            return
        }
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.chain = try container.decode(Chain.self, forKey: .chain)
        self.tokenId = try container.decodeIfPresent(String.self, forKey: .tokenId)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(identifier)
    }
}
