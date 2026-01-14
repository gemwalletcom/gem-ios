// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public struct ConfigUpdateRunner: AsyncRunnable {
    public let id = "config_update"

    private let configService: ConfigService

    public init(configService: ConfigService) {
        self.configService = configService
    }

    public func run() async throws {
        try await configService.updateConfig()
    }
}
