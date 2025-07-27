// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public struct HypercoreUniverseAsset: Codable, Sendable {
    public let name: String
    public let szDecimals: Int
    public let maxLeverage: Int
    public let onlyIsolated: Bool?
}

public struct HypercoreUniverseResponse: Codable, Sendable {
    public let universe: [HypercoreUniverseAsset]
}

public struct HypercoreMetadataResponse: Codable, Sendable {
    public let universe: HypercoreUniverseResponse
    public let assetMetadata: [HypercoreAssetMetadata]
    
    enum CodingKeys: CodingKey {
        case universe
        case assetMetadata
    }
    
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        self.universe = try container.decode(HypercoreUniverseResponse.self)
        self.assetMetadata = try container.decode([HypercoreAssetMetadata].self)
    }
}
