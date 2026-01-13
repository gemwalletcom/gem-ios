// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import AppService
import Store
import StoreTestKit
import GemAPI
import GemAPITestKit
import Primitives
import PrimitivesTestKit

public extension ConfigService {
    static func mock(
        configStore: ConfigStore = .mock(),
        apiService: any GemAPIConfigService = GemAPIConfigServiceMock(config: .mock())
    ) -> ConfigService {
        ConfigService(
            configStore: configStore,
            apiService: apiService
        )
    }
}
