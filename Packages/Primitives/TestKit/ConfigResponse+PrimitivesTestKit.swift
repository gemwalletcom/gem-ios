// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public extension ConfigResponse {
    static func mock(
        releases: [Release] = [.mock()],
        versions: ConfigVersions = .mock()
    ) -> Self {
        ConfigResponse(
            releases: releases,
            versions: versions
        )
    }
}

public extension Release {
    static func mock(
        version: String = "16.1",
        upgradeRequired: Bool = false
    ) -> Self {
        Release(
            version: version,
            store: .appStore,
            upgradeRequired: upgradeRequired
        )
    }
}

public extension ConfigVersions {
    static func mock(
        fiatOnRampAssets: Int32 = 0,
        fiatOffRampAssets: Int32 = 0,
        swapAssets: Int32 = 0
    ) -> Self {
        ConfigVersions(
            fiatOnRampAssets: fiatOnRampAssets,
            fiatOffRampAssets: fiatOffRampAssets,
            swapAssets: swapAssets
        )
    }
}
