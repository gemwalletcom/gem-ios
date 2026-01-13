// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import AppService

public extension ConfigUpdateRunner {
    static func mock(
        configService: ConfigService = .mock()
    ) -> ConfigUpdateRunner {
        ConfigUpdateRunner(configService: configService)
    }
}
