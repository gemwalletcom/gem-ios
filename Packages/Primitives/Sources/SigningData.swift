// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public enum SigningData: Sendable {
    case none
    case hyperliquid(Hyperliquid)
    
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
