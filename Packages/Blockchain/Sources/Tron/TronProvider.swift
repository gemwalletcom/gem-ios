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
    case listwitnesses
    case getReward(address: String)

    public var baseUrl: URL {
        return URL(string: "")!
    }
    
    public var path: String {
        switch self {
        case .account: "/wallet/getaccount"
        case .accountUsage: "/wallet/getaccountnet"
        case .latestBlock: "/wallet/getnowblock"
        case .transaction: "/wallet/gettransactionbyid"
        case .transactionReceipt: "/wallet/gettransactioninfobyid"
        case .triggerSmartContract: "/wallet/triggerconstantcontract"
        case .chainParams: "/wallet/getchainparameters"
        case .broadcast: "/wallet/broadcasttransaction"
        case .listwitnesses: "/wallet/listwitnesses"
        case .getReward: "/wallet/getReward"
        }
    }

    public var method: HTTPMethod {
        switch self {
        case .chainParams, .listwitnesses:
            return .GET
        case .account,
            .accountUsage,
            .latestBlock,
            .transaction,
            .transactionReceipt,
            .triggerSmartContract,
            .broadcast,
            .getReward:
            return .POST
        }
    }
    
    public var data: RequestData {
        switch self {
        case .account(let address), .accountUsage(let address), .getReward(let address):
            return .encodable(TronAccountRequest(address: address, visible: true))
        case .latestBlock,
            .chainParams,
            .listwitnesses:
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
