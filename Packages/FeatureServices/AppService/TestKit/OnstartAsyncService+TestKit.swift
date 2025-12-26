// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import AppService
import GemAPI
import GemAPITestKit
import PrimitivesTestKit

public extension OnstartAsyncService {
    static func mock(
        configService: any GemAPIConfigService = GemAPIConfigServiceMock(config: .mock()),
        runners: [any OnstartAsyncRunnable] = []
    ) -> OnstartAsyncService {
        OnstartAsyncService(
            configService: configService,
            runners: runners
        )
    }
}
