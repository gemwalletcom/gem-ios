// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GemAPI
import Primitives

public struct GemAPIConfigServiceMock: GemAPIConfigService {
    private let config: ConfigResponse
    
    public init(config: ConfigResponse) {
        self.config = config
    }
    
    public func getConfig() async throws -> ConfigResponse {
        config
    }
}
