// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public extension CosmosChain {
    
    static func from(string: String) throws -> CosmosChain {
        guard let chain = CosmosChain(rawValue: string) else {
            throw AnyError("Unknown cosmos chain: \(string)")
        }
        return chain
    }
    
    var chain: Chain {
        switch self {
        case .cosmos: .cosmos
        case .osmosis: .osmosis
        case .celestia: .celestia
        case .thorchain: .thorchain
        case .injective: .injective
        case .sei: .sei
        case .noble: .noble
        }
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
    
    var stakeLockTime: TimeInterval {
        switch self {
        case .thorchain, .noble: 0
        case .cosmos,
            .celestia,
            .injective,
            .sei: 1_814_400
        case .osmosis: 1_036_800
        }
    }
}
