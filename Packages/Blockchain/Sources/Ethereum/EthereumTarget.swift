// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftHTTPClient

public enum EthereumTarget: TargetType, BatchTargetType, Hashable {
    case gasPrice
    case estimateGasLimit(from: String, to: String, value: String?, data: String?)
    case transactionsCount(address: String)
    case call([String: String])
    case feeHistory(blocks: Int, rewardPercentiles: [Int], blockParameter: EthereumBlockParameter)
    case maxPriorityFeePerGas
    case syncing

    public var baseUrl: URL {
        return URL(string: "")!
    }
    
    public var rpc_method: String {
        switch self {
        case .gasPrice:
            return "eth_gasPrice"
        case .estimateGasLimit:
            return "eth_estimateGas"
        case .transactionsCount:
            return "eth_getTransactionCount"
        case .call:
            return "eth_call"
        case .feeHistory:
            return "eth_feeHistory"
        case .maxPriorityFeePerGas:
            return "eth_maxPriorityFeePerGas"
        case .syncing:
            return "eth_syncing"
        }
    }
    
    public var method: HTTPMethod {
        return .POST
    }
    
    public var path: String {
        return ""
    }
    
    public var data: RequestData {
        switch self {
        case .gasPrice,
            .maxPriorityFeePerGas,
            .syncing:
            return .encodable(
                JSONRPCRequest(method: rpc_method, params: [] as [String])
            )
        case .estimateGasLimit(let from, let to, let value, let data):
            let params = [
                "from": from,
                "to": to,
                "value": value,
                "data": data
            ].compactMapValues { $0 }
            
            return .encodable(
                JSONRPCRequest(method: rpc_method, params: [params])
            )
        case .transactionsCount(let address):
            return .encodable(
                JSONRPCRequest(method: rpc_method, params: [address, "latest"])
            )
        case .call(let params):
            let json: [JSON] = [.dictionary(params.mapValues { .value($0) }), .value("latest")]
            return .encodable(
                JSONRPCRequest(
                    method: rpc_method,
                    params: json
                )
            )
        case let .feeHistory(blocks, rewardPercentiles, param):
            let params: [JSON] = [
                .string("\(blocks)"),
                .string(param.rawValue),
                .array(rewardPercentiles.map { .value($0) })
            ]
            return .encodable(
                JSONRPCRequest(
                    method: rpc_method,
                    params: params
                )
            )
        }
    }
    
    public var contentType: String {
        return ContentType.json.rawValue
    }
}
