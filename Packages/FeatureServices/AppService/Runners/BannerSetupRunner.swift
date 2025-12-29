// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import BannerService
import Primitives

public struct BannerSetupRunner: AsyncRunnable {
    public let id = "banner_setup"

    private let bannerSetupService: BannerSetupService

    public init(bannerSetupService: BannerSetupService) {
        self.bannerSetupService = bannerSetupService
    }

    public func run() async throws {
        try bannerSetupService.setup()
    }
}
