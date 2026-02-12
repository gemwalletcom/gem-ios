// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import ChainService

public extension AddressStatusService {
    static func mock(
        chainServiceFactory: any ChainServiceFactorable = ChainServiceFactoryMock()
    ) -> AddressStatusService {
        AddressStatusService(chainServiceFactory: chainServiceFactory)
    }
}
