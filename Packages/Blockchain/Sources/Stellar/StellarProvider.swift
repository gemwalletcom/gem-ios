// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftHTTPClient

public enum StellarProvider: TargetType {
    case account(address: String)
    case fee
    case transaction(id: String)
    case node
    case assets(issuer: String)
    case broadcast(data: String)
    
    public var baseUrl: URL {
        return URL(string: "")!
    }
    
    public var method: HTTPMethod {
        switch self {
        case .account,
            .fee,
            .transaction,
            .assets,
            .node: .GET
        case .broadcast: .POST
        }
    }
    
    public var path: String {
        switch self {
        case .account(let address): "/accounts/\(address)"
        case .fee: "/fee_stats"
        case .transaction(let id): "/transactions/\(id)"
        case .node: "/"
        case .assets: "/assets"
        case .broadcast: "/transactions"
        }
    }
    
    public var data: RequestData {
        switch self {
        case .account,
            .fee,
            .transaction,
            .node: .plain
        case .assets(let issuer):
                .params(["asset_issuer": issuer, "limit": 200])
        case .broadcast(let data):
                .params(["tx": data.addingPercentEncoding(withAllowedCharacters: .alphanumerics)!])
        }
    }
    
    public var contentType: String {
        switch self {
        case .account,
            .fee,
            .transaction,
            .node,
            .assets: ContentType.json.rawValue
        case .broadcast: ContentType.URLEncoded.rawValue
        }
    }
}
