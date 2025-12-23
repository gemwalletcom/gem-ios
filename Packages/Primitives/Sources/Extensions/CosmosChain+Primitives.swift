// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public extension CosmosChain {
    
    static func from(string: String) throws -> CosmosChain {
        guard let chain = CosmosChain(rawValue: string) else {
            throw AnyError("Unknown cosmos chain: \(string)")
        }
        return chain
    }
    
    var denom: CosmosDenom {
        switch self {
        case .thorchain: CosmosDenom.rune
        case .cosmos: CosmosDenom.uatom
        case .osmosis: CosmosDenom.uosmo
        case .celestia: CosmosDenom.utia
        case .injective: CosmosDenom.inj
        case .sei: CosmosDenom.usei
        case .noble: CosmosDenom.uusdc
        }
    }
}
