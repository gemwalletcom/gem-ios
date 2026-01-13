// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Store
import GemAPI

public struct ConfigService: Sendable {
    private let configStore: ConfigStore
    private let apiService: any GemAPIConfigService

    public init(
        configStore: ConfigStore,
        apiService: any GemAPIConfigService = GemAPIService()
    ) {
        self.configStore = configStore
        self.apiService = apiService
    }

    public func getConfig() throws -> ConfigResponse? {
        try configStore.get()
    }

    public func updateConfig() async throws {
        try configStore.update(try await apiService.getConfig())
    }
}
