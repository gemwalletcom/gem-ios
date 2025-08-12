// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public struct HyperCoreServiceConfig: Sendable {
    public let builderAddress: String
    public let referralCode: String
    public let maxBuilderFeeBps: Int
    
    public init(
        builderAddress: String,
        referralCode: String,
        maxBuilderFeeBps: Int
    ) {
        self.builderAddress = builderAddress
        self.referralCode = referralCode
        self.maxBuilderFeeBps = maxBuilderFeeBps
    }
}