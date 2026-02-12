// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import ScanService
import Primitives
import Blockchain
import NativeProviderService

public extension ScanService {
    static func mock() -> ScanService {
        let mockProvider = NativeProvider(url: Constants.apiURL, requestInterceptor: EmptyRequestInterceptor())
        let gatewayService = GatewayService(provider: mockProvider)
        return ScanService(gatewayService: gatewayService)
    }
}
