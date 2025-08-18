// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GemstonePrimitives

public struct HyperCoreConfig: Sendable {
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

public extension HyperCoreConfig {
    static func create() -> HyperCoreConfig {
        let perpetualConfig = GemstoneConfig.shared.perpetualConfig()
        
        return HyperCoreConfig(
            builderAddress: perpetualConfig.builderAddress,
            referralCode: perpetualConfig.referralCode,
            maxBuilderFeeBps: Int(perpetualConfig.maxBuilderFeeBps)
        )
    }
}
