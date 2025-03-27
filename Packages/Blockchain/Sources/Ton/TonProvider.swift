// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftHTTPClient

public enum TonProvider: TargetType {
    case balance(address: String)
    case walletInformation(address: String)
    case transaction(hash: String)
    case estimateFee(address: String, data: String)
    case addressState(address: String)
    case tokenData(id: String)
    case runGetMethod(address: String, method: String, stack: [String])
    case masterChainInfo
    case broadcast(data: String)
    
    public var baseUrl: URL {
        return URL(string: "")!
    }
    
    public var path: String {
        switch self {
        case .balance: "/api/v2/getAddressBalance"
        case .walletInformation: "/api/v2/getWalletInformation"
        case .transaction: "/api/v3/transactionsByMessage"
        case .estimateFee: "/api/v2/estimateFee"
        case .addressState: "/api/v2/getAddressState"
        case .tokenData: "/api/v2/getTokenData"
        case .runGetMethod: "/api/v2/jsonRPC"
        case .masterChainInfo: "/api/v2/getMasterchainInfo"
        case .broadcast: "/api/v2/sendBocReturnHash"
        }
    }

    public var method: HTTPMethod {
        switch self {
        case .balance,
            .walletInformation,
            .transaction,
            .tokenData,
            .addressState,
            .masterChainInfo:
            return .GET
        case .estimateFee,
            .runGetMethod,
            .broadcast:
            return .POST
        }
    }
    
    public var data: RequestData {
        switch self {
        case .balance(let address),
            .walletInformation(let address):
            return .params(["address": address])
        case .transaction(let hash):
            return .params(["msg_hash": hash])
        case .estimateFee(let address, let data):
            return .encodable(
                [
                    "address": address,
                    "body": data,
                    "init_code": "",
                    "init_data": "",
                    //"ignore_chksig": true
                ]
            )
        case .addressState(let address):
            return .params(["address": address])
        case .tokenData(let id):
            return .params(["address": id])
        case .runGetMethod(let address, let method, let stack):
            let stackString = JSON.array(stack.map { JSON.value($0) })
            let stack = JSON.array([stackString])
            return .encodable(
                JSONRPCRequest(method: "runGetMethod", params: JSON.dictionary([
                    "address": .value(address),
                    "method": .value(method),
                    "stack": stack,
                ]))
            )
        case .masterChainInfo:
            return .plain
        case .broadcast(let data):
            return .encodable(["boc": data])
        }
    }
    
    public var contentType: String {
        return ContentType.json.rawValue
    }
}

