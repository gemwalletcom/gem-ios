// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftHTTPClient

public enum SolanaProvider: TargetType {
    
    public struct Options: Sendable {
        let skipPreflight: Bool
    }
    
    case balance(address: String)
    case getTokenAccountsByOwner(owner: String, token: String)
    case getTokenAccountBalance(token: String)
    case latestBlockhash
    case fees
    case slot
    case rentExemption(size: Int)
    case broadcast(data: String, options: Options?)
    case transaction(id: String)
    case stakeDelegations(address: String)
    case stakeValidators
    case epoch
    case health
    case getAccountInfo(account: String)
    case genesisHash

    public var baseUrl: URL {
        return URL(string: "")!
    }
    
    public var rpc_method: String {
        switch self {
        case .balance: "getBalance"
        case .getTokenAccountsByOwner: "getTokenAccountsByOwner"
        case .getTokenAccountBalance: "getTokenAccountBalance"
        case .latestBlockhash: "getLatestBlockhash"
        case .fees: "getRecentPrioritizationFees"
        case .slot: "getSlot"
        case .rentExemption: "getMinimumBalanceForRentExemption"
        case .broadcast: "sendTransaction"
        case .transaction: "getTransaction"
        case .stakeDelegations: "getProgramAccounts"
        case .stakeValidators: "getVoteAccounts"
        case .epoch: "getEpochInfo"
        case .health: "getHealth"
        case .getAccountInfo: "getAccountInfo"
        case .genesisHash: "getGenesisHash"
        }
    }
    
    public var method: HTTPMethod {
        return .POST
    }
    
    public var path: String {
        return "/"
    }
    
    public var data: RequestData {
        switch self {
        case .latestBlockhash,
            .fees,
            .slot,
            .epoch,
            .health,
            .genesisHash:
            return .encodable(
                JSONRPCRequest(method: rpc_method, params: [] as [String], id: 1)
            )
        case .balance(let address):
            return .encodable(
                JSONRPCRequest(method: rpc_method, params: [address], id: 1)
            )
        case .getTokenAccountsByOwner(let owner, let token):
            let params: [JSON] = [
                .value(owner),
                .dictionary(["mint": .value(token)]),
                .dictionary(["encoding": .value("jsonParsed")]),
            ]
            return .encodable(
                JSONRPCRequest(method: rpc_method, params: params, id: 1)
            )
        case .getTokenAccountBalance(let token):
            return .encodable(
                JSONRPCRequest(method: rpc_method, params: [token], id: 1)
            )
        case .rentExemption(let size):
            return .encodable(
                JSONRPCRequest(method: rpc_method, params: [size], id: 1)
            )
        case .broadcast(let data, let options):
            
            // JSON enum is hard to manipulate
            var params: [JSON] = [
                .string(data),
                .dictionary(["encoding": .value("base64")])
            ]
            
            if let options = options {
                params = [
                    .string(data),
                    .dictionary([
                        "encoding": .value("base64"),
                        "skipPreflight": .bool(options.skipPreflight),
                    ])
                ]
            }
            
            return .encodable(
                JSONRPCRequest(method: rpc_method, params: params, id: 2)
            )
        case .transaction(let id):
            let params: [JSON] = [
                .value(id),
                .dictionary([
                    "encoding": .value("jsonParsed"),
                    "maxSupportedTransactionVersion": .integer(0)
                ]),
            ]
            return .encodable(
                JSONRPCRequest(method: rpc_method, params: params, id: 1)
            )
        case .stakeDelegations(let address):
            let params: [JSON] = [
                .value("Stake11111111111111111111111111111111111111"),
                .dictionary([
                    "encoding": .value("jsonParsed"),
                    "commitment": .value("finalized"),
                    "filters": .array([
                        .dictionary([
                            "memcmp": .dictionary([
                                "bytes": .value(address),
                                "offset": .integer(44)
                            ])
                        ])
                    ])
                ]),
            ]
            return .encodable(
                JSONRPCRequest(method: rpc_method, params: params, id: 1)
            )
        case .stakeValidators:
            let params: [JSON<String>] = [
                .dictionary([
                    "commitment": .string("finalized"),
                    "keepUnstakedDelinquents": .bool(false)
                ])
            ]
            return .encodable(
                JSONRPCRequest(method: rpc_method, params: params, id: 1)
            )
        case .getAccountInfo(let account):
            let params: [JSON] = [
                .string(account),
                .dictionary(["encoding": .value("jsonParsed")]),
            ]
            return .encodable(
                JSONRPCRequest(method: rpc_method, params: params, id: 1)
            )
        }
    }
    
    public var contentType: String {
        return ContentType.json.rawValue
    }
}
