// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftHTTPClient

public enum TronProvider: TargetType {
    case account(address: String)
    case accountUsage(address: String)
    case latestBlock
    case transaction(id: String)
    case transactionReceipt(id: String)
    case triggerSmartContract(TronSmartContractCall)
    case chainParams
    case broadcast(data: String)
    
    public var baseUrl: URL {
        return URL(string: "")!
    }
    
    public var path: String {
        switch self {
        case .account:
            return "/wallet/getaccount"
        case .accountUsage:
            return "/wallet/getaccountnet"
        case .latestBlock:
            return "/wallet/getnowblock"
        case .transaction:
            return "/wallet/gettransactionbyid"
        case .transactionReceipt:
            return "/wallet/gettransactioninfobyid"
        case .triggerSmartContract:
            return "/wallet/triggerconstantcontract"
        case .chainParams:
            return "/wallet/getchainparameters"
        case .broadcast:
            return "/wallet/broadcasttransaction"
        }
    }

    public var method: HTTPMethod {
        switch self {
        case .chainParams:
            return .GET
        case .account,
            .accountUsage,
            .latestBlock,
            .transaction,
            .transactionReceipt,
            .triggerSmartContract,
            .broadcast:
            return .POST
        }
    }
    
    public var task: Task {
        switch self {
        case .account(let address), .accountUsage(let address):
            return .encodable(TronAccountRequest(address: address, visible: true))
        case .latestBlock,
            .chainParams:
            return .plain
        case .transaction(let id), .transactionReceipt(let id):
            return .encodable(["value": id])
        case .triggerSmartContract(let value):
            return .encodable(value)
        case .broadcast(let data):
            return .data(Data(data.utf8))
        }
    }
    
    public var contentType: String {
        return ContentType.json.rawValue
    }
}
