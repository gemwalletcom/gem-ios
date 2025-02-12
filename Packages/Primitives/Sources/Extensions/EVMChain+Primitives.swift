// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

extension EVMChain {
    
    public var chain: Chain {
        Chain(rawValue: self.rawValue)!
    }
    
    public init(from chain: Chain) throws {
        guard let evmChain = EVMChain(rawValue: chain.rawValue) else {
            throw AnyError("Not EVM compatible chain!")
        }
        self = evmChain
    }
}
