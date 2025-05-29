// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import ChainService

public extension AddressStatusService {
    static func mock(
        chainServiceFactory: ChainServiceFactory = .mock()
    ) -> AddressStatusService {
        AddressStatusService(chainServiceFactory: chainServiceFactory)
    }
}
