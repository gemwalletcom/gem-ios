// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public enum DeepLink: Sendable {

    static let host = "gemwallet.com"

    case asset(AssetId)
    case swap(AssetId, AssetId?)
    case perpetuals

    public var path: String {
        switch self {
        case .asset(let assetId):
            switch assetId.tokenId {
            case .some(let tokenId): "/tokens/\(assetId.chain.rawValue)/\(tokenId)"
            case .none: "/tokens/\(assetId.chain.rawValue)"
            }
        case let .swap(fromAssetId, toAssetId):
            switch toAssetId {
            case .some(let id): "/swap/\(fromAssetId.identifier)/\(id.identifier)"
            case .none: "/swap/\(fromAssetId.identifier)"
            }
        case .perpetuals: "/perpetuals"
        }
    }
    
    public var url: URL {
        URL(string: "https://\(Self.host)\(path)")!
    }
    
    public var localUrl: URL {
        URL(string: "gem://\(path)")!
    }
}
