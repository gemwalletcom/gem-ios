// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import StakeService
import GemAPI
import ChainService
import ChainServiceTestKit
import Store
import StoreTestKit

public extension StakeService {
    static func mock(
        store: StakeStore = .mock(),
        addressStore: AddressStore = .mock(),
        chainServiceFactory: any ChainServiceFactorable = ChainServiceFactoryMock(),
        assetsService: GemAPIStaticService = GemAPIStaticService()
    ) -> Self {
        StakeService(
            store: store,
            addressStore: addressStore,
            chainServiceFactory: chainServiceFactory,
            assetsService: assetsService
        )
    }
}
