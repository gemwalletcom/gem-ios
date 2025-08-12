// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GemstonePrimitives

public struct HyperCoreServiceConfigProvider {
    public static func createConfig() -> HyperCoreServiceConfig {
        let perpetualConfig = GemstoneConfig.shared.perpetualConfig()
        
        return HyperCoreServiceConfig(
            builderAddress: perpetualConfig.builderAddress,
            referralCode: perpetualConfig.referralCode,
            maxBuilderFeeBps: Int(perpetualConfig.maxBuilderFeeBps)
        )
    }
}