// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftHTTPClient

public enum PolkadotProvider: TargetType {
    case balance(address: String)
    case asset(id: String)
    case block(id: String)
    case blockHead
    case blocks(range: String)
    case nodeVersion
    case transactionMaterial
    case estimateFee(String)
    case broadcast(data: String)
    
    public var baseUrl: URL {
        return URL(string: "")!
    }
    
    public var method: HTTPMethod {
        switch self {
        case .balance,
            .asset,
            .block,
            .blockHead,
            .blocks,
            .nodeVersion,
            .transactionMaterial: .GET
        case .estimateFee,
            .broadcast: .POST
        }
    }
    
    public var path: String {
        switch self {
        case .balance(let address): "/accounts/\(address)/balance-info"
        case .asset(let id): "/pallets/assets/\(id)/asset-info"
        case .block(let id): "/blocks/\(id)"
        case .blocks: "/blocks"
        case .blockHead: "/blocks/head"
        case .nodeVersion: "/node/version"
        case .transactionMaterial: "/transaction/material?noMeta=true"
        case .estimateFee: "/transaction/fee-estimate"
        case .broadcast: "/transaction"
        }
    }
    
    public var data: RequestData {
        switch self {
        case .balance,
            .asset,
            .block,
            .blockHead,
            .nodeVersion,
            .transactionMaterial:
            .plain
        case .blocks(let range):
            .params(["range": range, "noFees": "true"])
        case .estimateFee(let data):
            .encodable(PolkadotTransactionPayload(tx: data))
        case .broadcast(let data):
            .encodable(PolkadotTransactionPayload(tx: data))
        }
    }
    
    public var contentType: String {
        switch self {
        case .balance,
            .asset,
            .block,
            .blockHead,
            .blocks,
            .nodeVersion,
            .transactionMaterial,
            .estimateFee,
            .broadcast: ContentType.json.rawValue
        }
    }
}
