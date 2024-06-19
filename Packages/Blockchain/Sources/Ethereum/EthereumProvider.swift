// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftHTTPClient

public enum EthereumProvider: TargetType {
    case chainId
    case gasPrice
    case estimateGasLimit(from: String, to: String, value: String?, data: String?)
    case transactionsCount(address: String)
    case balance(address: String)
    case broadcast(data: String)
    case call([String: String])
    case transactionReceipt(id: String)
    case blockByNumber(block: String)
    case feeHistory(blocks: Int, rewardPercentiles: [Int])
    case maxPriorityFeePerGas
    case syncing
    case latestBlock

    public var baseUrl: URL {
        return URL(string: "")!
    }
    
    public var rpc_method: String {
        switch self {
        case .chainId:
            return "eth_chainId"
        case .gasPrice:
            return "eth_gasPrice"
        case .estimateGasLimit:
            return "eth_estimateGas"
        case .transactionsCount:
            return "eth_getTransactionCount"
        case .balance:
            return "eth_getBalance"
        case .broadcast:
            return "eth_sendRawTransaction"
        case .call:
            return "eth_call"
        case .transactionReceipt:
            return "eth_getTransactionReceipt"
        case .blockByNumber:
            return "eth_getBlockByNumber"
        case .feeHistory:
            return "eth_feeHistory"
        case .maxPriorityFeePerGas:
            return "eth_maxPriorityFeePerGas"
        case .syncing:
            return "eth_syncing"
        case .latestBlock:
            return "eth_blockNumber"
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
        case .chainId,
            .gasPrice,
            .maxPriorityFeePerGas,
            .syncing,
            .latestBlock:
            return .encodable(
                JSONRPCRequest(method: rpc_method, params: [] as [String], id: 1)
            )
        case .estimateGasLimit(let from, let to, let value, let data):
            let params = [
                "from": from,
                "to": to,
                "value": value,
                "data": data
            ].compactMapValues { $0 }
            
            return .encodable(
                JSONRPCRequest(method: rpc_method, params: [params], id: 1)
            )
        case .transactionsCount(let address):
            return .encodable(
                JSONRPCRequest(method: rpc_method, params: [address, "latest"], id: 1)
            )
        case .balance(let address):
            return .encodable(
                JSONRPCRequest(method: rpc_method, params: [address, "latest"], id: 1)
            )
        case .broadcast(let data):
            return .encodable(
                JSONRPCRequest(method: rpc_method, params: [data.append0x], id: 1)
            )
        case .call(let params):
            let json: [JSON] = [.dictionary(params.mapValues { .value($0) }), .value("latest")]
            return .encodable(
                JSONRPCRequest(
                    method: rpc_method,
                    params: json,
                    id: 1
                )
            )
        case .blockByNumber(let block):
            let params: [JSON] = [.value(block), .bool(false)]
            return .encodable(
                JSONRPCRequest(
                    method: rpc_method,
                    params: params,
                    id: 1
                )
            )
        case .feeHistory(let blocks, let rewardPercentiles):
            let params: [JSON] = [
                .string("\(blocks)"),
                .string("latest"),
                .array(rewardPercentiles.map { .value($0) })
            ]
            return .encodable(
                JSONRPCRequest(
                    method: rpc_method,
                    params: params,
                    id: 1
                )
            )
        case .transactionReceipt(let id):
            return .encodable(
                JSONRPCRequest(method: rpc_method, params: [id] as [String], id: 1)
            )
        }
    }
    
    public var contentType: String {
        return ContentType.json.rawValue
    }
}
