// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import NFTService
import StoreTestKit
import DeviceServiceTestKit

public extension NFTService {
    static func mock() -> NFTService {
        NFTService(
            nftStore: .mock(),
            deviceService: DeviceServiceMock()
        )
    }
}
