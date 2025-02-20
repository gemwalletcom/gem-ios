// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public enum DeepLink {
    
    static let host = "gemwallet.com"
    
    case asset(AssetId)
    
    public var path: String {
        switch self {
        case .asset(let assetId):
            switch assetId.tokenId {
            case .some(let tokenId): "/tokens/\(assetId.chain.rawValue)/\(tokenId)"
            case .none: "/tokens/\(assetId.chain.rawValue)"
            }
        }
    }
    
    public var url: URL {
        return URL(string: "https://\(Self.host)\(path)")!
    }
    
    public var localUrl: URL {
        return URL(string: "gem://\(path)")!
    }
}
