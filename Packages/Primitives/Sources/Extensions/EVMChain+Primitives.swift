// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

extension EVMChain {
    
    public var chain: Chain {
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
        }
    }
    
    public var isOpStack: Bool {
        switch self {
        case .optimism,
            .base,
            .opBNB,
            .blast,
            .mantle,
            .celo:
            return true
        case .ethereum,
            .smartChain,
            .polygon,
            .arbitrum,
            .avalancheC,
            .fantom,
            .gnosis,
            .manta,
            .zkSync,
            .linea:
            return false
        }
    }
    
    public init(from chain: Chain) throws {
        guard let evmChain = EVMChain(rawValue: chain.rawValue) else {
            throw AnyError("Not EVM compatible chain!")
        }
        self = evmChain
    }
}
