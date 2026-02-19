// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import BigInt

extension Chain {
    public init(id: String) throws {
        if let chain = Chain(rawValue: id) {
            self = chain
        } else {
            throw AnyError("invalid chain id: \(id)")
        }
    }
    
    public var assetId: AssetId {
        AssetId(chain: self, tokenId: .none)
    }
    
    // in most cases address is the case, except bitcoin cash
    // short and full simplifies bitcoincash address
    public func shortAddress(address: String) -> String {
        switch self {
        case .bitcoinCash: address.removePrefix("\(self.rawValue):")
        default: address
        }
    }
    
    public func fullAddress(address: String) -> String {
        switch self {
        case .bitcoinCash: address.addPrefix("\(self.rawValue):")
        default: address
        }
    }
}

extension Chain: Identifiable {
    public var id: String { rawValue }
}

extension Chain {
    public var stakeChain: StakeChain? {
        StakeChain(rawValue: rawValue)
    }
}

extension Chain: Comparable {
    public static func < (lhs: Chain, rhs: Chain) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

extension Chain {
    public var evmChain: EVMChain? {
        EVMChain(rawValue: rawValue)
    }

    public var isEvm: Bool {
        evmChain != nil
    }
}
