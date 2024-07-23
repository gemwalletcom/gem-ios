// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftHTTPClient

public enum AptosProvider: TargetType {
    case ledger
    case account(address: String)
    case balance(address: String)
    case transaction(id: String)
    case gasPrice
    case estimateFee(data: Data)
    case broadcast(data: String)
    
    public var baseUrl: URL {
        return URL(string: "")!
    }
    
    public var method: HTTPMethod {
        switch self {
        case .ledger,
            .account,
            .balance,
            .transaction,
            .gasPrice:
            return .GET
        case .estimateFee,
            .broadcast:
            return .POST
        }
    }
    
    public var path: String {
        switch self {
        case .ledger: "/v1"
        case .account(let address): "/v1/accounts/\(address)"
        case .balance(let address): "/v1/accounts/\(address)/resource/0x1::coin::CoinStore<0x1::aptos_coin::AptosCoin>"
        case .transaction(let id): "/v1/transactions/by_hash/\(id)"
        case .gasPrice: "/v1/estimate_gas_price"
        case .estimateFee: "/v1/transactions/simulate?estimate_max_gas_amount=true&estimate_gas_unit_price=true&estimate_prioritized_gas_unit_price=false"
        case .broadcast: "/v1/transactions"
        }
    }
    
    public var task: Task {
        switch self {
        case .ledger,
            .account,
            .balance,
            .transaction,
            .gasPrice:
            return .plain
        case .estimateFee(let data):
            return .data(data)
        case .broadcast(let data):
            return .data(Data(data.utf8))
        }
    }
    
    public var contentType: String {
        return ContentType.json.rawValue
    }
}
