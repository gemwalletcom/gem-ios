// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public enum SigningData: Sendable {
    case none
    case polkadot(Polkadot)
    case hyperliquid(Hyperliquid)
    
    public struct Polkadot: Sendable {
        public let genesisHash: Data
        public let blockHash: Data
        public let blockNumber: UInt64
        public let specVersion: UInt32
        public let transactionVersion: UInt32
        public let period: UInt64
        
        public init(genesisHash: Data, blockHash: Data, blockNumber: UInt64, specVersion: UInt32, transactionVersion: UInt32, period: UInt64) {
            self.genesisHash = genesisHash
            self.blockHash = blockHash
            self.blockNumber = blockNumber
            self.specVersion = specVersion
            self.transactionVersion = transactionVersion
            self.period = period
        }
    }
    
    public struct Hyperliquid: Sendable {
        public let approveAgentRequired: Bool
        public let approveReferralRequired: Bool
        public let approveBuilderRequired: Bool
        public let builderFeeBps: Int
        
        public init(
            approveAgentRequired: Bool,
            approveReferralRequired: Bool,
            approveBuilderRequired: Bool,
            builderFeeBps: Int
        ) {
            self.approveAgentRequired = approveAgentRequired
            self.approveReferralRequired = approveReferralRequired
            self.approveBuilderRequired = approveBuilderRequired
            self.builderFeeBps = builderFeeBps
        }
    }
}
