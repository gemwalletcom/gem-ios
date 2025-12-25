// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import BannerService
import Primitives

public struct BannerSetupRunner: OnstartAsyncRunnable {
    private let bannerSetupService: BannerSetupService

    public init(bannerSetupService: BannerSetupService) {
        self.bannerSetupService = bannerSetupService
    }

    public func run(config: ConfigResponse?) async throws {
        try bannerSetupService.setup()
    }
}
