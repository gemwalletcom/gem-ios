// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import AppService
import BannerService
import BannerServiceTestKit

public extension BannerSetupRunner {
    static func mock(
        bannerSetupService: BannerSetupService = .mock()
    ) -> BannerSetupRunner {
        BannerSetupRunner(bannerSetupService: bannerSetupService)
    }
}
