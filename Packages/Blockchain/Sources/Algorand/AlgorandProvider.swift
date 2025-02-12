// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftHTTPClient

public enum AlgorandProvider: TargetType {
    case account(address: String)
    case transactionsParams
    case asset(id: String)
    case transaction(id: String)
    case broadcast(data: String)
    
    public var baseUrl: URL {
        return URL(string: "")!
    }
    
    public var method: HTTPMethod {
        switch self {
        case .account,
            .transactionsParams,
            .asset,
            .transaction: .GET
        case .broadcast: .POST
        }
    }
    
    public var path: String {
        switch self {
        case .account(let address): "/v2/accounts/\(address)"
        case .transactionsParams: "/v2/transactions/params"
        case .asset(let id): "/v2/assets/\(id)"
        case .transaction(let id): "/v2/transactions/pending/\(id)"
        case .broadcast: "/v2/transactions"
        }
    }
    
    public var data: RequestData {
        switch self {
        case .account,
            .transactionsParams,
            .asset,
            .transaction:
            .plain
        case .broadcast(let data):
            .data(Data(hexString: data)!)
        }
    }
    
    public var contentType: String {
        switch self {
        case .account,
            .transactionsParams,
            .asset,
            .transaction: ContentType.json.rawValue
        case .broadcast: ContentType.XBinary.rawValue
        }
    }
}
