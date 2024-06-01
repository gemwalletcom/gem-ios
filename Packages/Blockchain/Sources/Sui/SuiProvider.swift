// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftHTTPClient

public enum SuiProvider: TargetType {
    case coins(address: String, coinType: String)
    case balance(address: String)
    case balances(address: String)
    case gasPrice
    case moveCall(SuiMoveCallRequest)
    case dryRun(data: String)
    case transaction(id: String)
    case stakeDelegations(address: String)
    case stakeValidators
    case batch(SuiBatchRequest)
    case broadcast(data: String, signature: String)
    case getObject(id: String)
    case coinMetadata(id: String)
    case systemState
    
    public var baseUrl: URL {
        return URL(string: "")!
    }
    
    public var rpc_method: String {
        switch self {
        case .coins: "suix_getCoins"
        case .balance: "suix_getBalance"
        case .balances: "suix_getAllBalances"
        case .gasPrice: "suix_getReferenceGasPrice"
        case .moveCall: "unsafe_moveCall"
        case .dryRun: "sui_dryRunTransactionBlock"
        case .transaction: "sui_getTransactionBlock"
        case .stakeDelegations: "suix_getStakes"
        case .stakeValidators: "suix_getValidatorsApy"
        case .batch: "unsafe_batchTransaction"
        case .broadcast: "sui_executeTransactionBlock"
        case .getObject: "sui_getObject"
        case .coinMetadata: "suix_getCoinMetadata"
        case .systemState: "suix_getLatestSuiSystemState"
        }
    }
    
    public var method: HTTPMethod {
        return .POST
    }
    
    public var path: String {
        return "/"
    }
    
    public var task: Task {
        switch self {
        case .coins(let address, let coinType):
            return .encodable(
                JSONRPCRequest(method: rpc_method, params: [address, coinType], id: 1)
            )
        case .balance(let address), .balances(let address):
            return .encodable(
                JSONRPCRequest(method: rpc_method, params: [address], id: 1)
            )
        case .gasPrice:
            return .encodable(
                JSONRPCRequest(method: rpc_method, params: [:] as [String: String], id: 1)
            )
        case .moveCall(let request):
            let params: [JSON] = [
                .value(request.senderAddress),
                .value(request.objectId),
                .value(request.module),
                .value(request.function),
                .array([] as [JSON<String>]),
                .array(request.arguments.map { .value($0) }),
                .value(request.gasBudget),
            ]
            return .encodable(
                JSONRPCRequest(method: rpc_method, params: params, id: 1)
            )
        case .dryRun(let data):
            return .encodable(
                JSONRPCRequest(method: rpc_method, params: [data], id: 1)
            )
        case .transaction(let id):
            let params: [JSON] = [
                .value(id),
                .dictionary(["showEffects": .bool(true)])
            ]
            return .encodable(
                JSONRPCRequest(method: rpc_method, params: params, id: 1)
            )
        case .stakeDelegations(let address):
            return .encodable(
                JSONRPCRequest(method: rpc_method, params: [address], id: 1)
            )
        case .stakeValidators:
            return .encodable(
                JSONRPCRequest(method: rpc_method, params: [:] as [String: String], id: 1)
            )
        case .batch(let request):
            let params: [JSON] = [
                .value(request.senderAddress),
                .array([.string("")]),
                .null,
                .value(request.gasBudget),
                .null,
            ]
            return .encodable(
                JSONRPCRequest(method: rpc_method, params: params, id: 1)
            )
        case .broadcast(let data, let signature):
            let params: [JSON] = [
                .value(data),
                .array([.string(signature)]),
                .null,
                .value("WaitForLocalExecution")
            ]
            return .encodable(
                JSONRPCRequest(method: rpc_method, params: params, id: 1)
            )
        case .getObject(let id):
            let params: [JSON] = [
                .value(id),
            ]
            return .encodable(
                JSONRPCRequest(method: rpc_method, params: params, id: 2)
            )
        case .coinMetadata(let id):
            return .encodable(
                JSONRPCRequest(method: rpc_method, params: [id], id: 1)
            )
        case .systemState:
            return .encodable(
                JSONRPCRequest(method: rpc_method, params: [] as [String], id: 1)
            )
        }
    }
    
    public var contentType: String {
        return ContentType.json.rawValue
    }
}
