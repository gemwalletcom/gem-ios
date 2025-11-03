// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

extension Asset: Identifiable {}

extension Asset {
    
    public var chain: Chain {
        return id.chain
    }
    
    public var tokenId: String? {
        return id.tokenId
    }
    
    public var feeAssetId: AssetId {
        switch id.type {
        case .native:
            return self.id
        case .token:
            return id.chain.assetId
        }
    }
    
    public func getTokenId() throws -> String {
        try id.getTokenId()
    }
    
    public func getTokenIdAsInt() throws -> Int {
        guard let tokenId = tokenId, let tokenId = UInt64(tokenId) else {
            throw AnyError("tokenId is null")
        }
        return Int(tokenId)
    }
}

public extension Array where Element == Asset {
    var ids: [String] {
        return self.map { $0.id.identifier }
    }
    
    var assetIds: [AssetId] {
        return self.map { $0.id }
    }
}

public extension Array where Element == Chain {
    var ids: [AssetId] {
        return self.compactMap { $0.assetId }
    }
}

public extension AssetFull {
    var basic: AssetBasic {
        AssetBasic(
            asset: asset,
            properties: properties,
            score: score
        )
    }
}

// MARK: - Assets

extension Asset {
    
    public static func hypercoreUSDC() -> Asset {
        Asset(
            id: AssetId(chain: .hyperCore, tokenId: "perpetual::USDC"),
            name: "USDC",
            symbol: "USDC",
            decimals: 6,
            type: .perpetual
        )
    }
    
    public static func hypercoreSpotUSDC() -> Asset {
        Asset(
            id: AssetId(chain: .hyperCore, tokenId: "USDC::0x6d1e7cde53ba9467b783cb7c530ce054::0"),
            name: "USDC",
            symbol: "USDC",
            decimals: 8,
            type: .token
        )
    }
}
