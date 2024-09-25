import Foundation

extension Asset: Hashable {
    public static func == (lhs: Asset, rhs: Asset) -> Bool {
        return lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

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
        guard let tokenId = tokenId else {
            throw AnyError("tokenId is null")
        }
        return tokenId
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

public extension Array where Element == AssetId {
    var ids: [String] {
        return self.map { $0.identifier }
    }
}

public extension Array where Element == Chain {
    var ids: [AssetId] {
        return self.compactMap { $0.assetId }
    }
}
