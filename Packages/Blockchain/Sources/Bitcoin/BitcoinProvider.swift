// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftHTTPClient

public enum BitcoinProvider: TargetType {
    case balance(address: String)
    case transaction(id: String)
    case nodeInfo
    case utxo(address: String)
    case fee(priority: Int)
    case block(block: Int)
    case broadcast(data: String)
    
    public var baseUrl: URL {
        return URL(string: "")!
    }
    
    public var path: String {
        switch self {
        case .balance(let address):
            return "/api/v2/address/\(address)"
        case .transaction(let id):
            return "/api/v2/tx/\(id)"
        case .nodeInfo:
            return "/api/v2/"
        case .utxo(let address):
            return "/api/v2/utxo/\(address)"
        case .fee(let priority):
            return "/api/v2/estimatefee/\(priority)"
        case .block(let block):
            return "/api/v2/block/\(block)"
        case .broadcast:
            return "/api/v2/sendtx/"
        }
    }

    public var method: HTTPMethod {
        switch self {
        case .balance,
            .transaction,
            .nodeInfo,
            .utxo,
            .fee,
            .block:
            return .GET
        case .broadcast:
            return .POST
        }
    }
    
    public var data: RequestData {
        switch self {
        case .balance,
            .transaction,
            .nodeInfo,
            .utxo,
            .fee,
            .block:
            return .plain
        case .broadcast(let data):
            return .data(Data(data.utf8))
        }
    }
    
    public var contentType: String {
        switch self {
        case .broadcast:
            return ContentType.plainText.rawValue
        default:
            return ContentType.json.rawValue
        }
    }
}
