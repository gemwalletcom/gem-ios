// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public extension EVMChain {
    var chain: Chain {
        switch self {
        case .ethereum: .ethereum
        case .smartChain: .smartChain
        case .polygon: .polygon
        case .arbitrum: .arbitrum
        case .optimism: .optimism
        case .base: .base
        case .avalancheC: .avalancheC
        case .opBNB: .opBNB
        case .fantom: .fantom
        case .gnosis: .gnosis
        case .manta: .manta
        case .blast: .blast
        case .zkSync: .zkSync
        case .linea: .linea
        case .mantle: .mantle
        case .celo: .celo
        case .world: .world
        case .sonic: .sonic
        case .abstract: .abstract
        case .ink: .ink
        case .berachain: .berachain
        case .unichain: .unichain
        }
    }

    init(from chain: Chain) throws {
        guard let evmChain = EVMChain(rawValue: chain.rawValue) else {
            throw AnyError("Not EVM compatible chain!")
        }
        self = evmChain
    }
}
