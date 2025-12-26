// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import AppService
import DeviceService
import DeviceServiceTestKit

public extension DeviceUpdateRunner {
    static func mock(
        deviceService: DeviceService = .mock()
    ) -> DeviceUpdateRunner {
        DeviceUpdateRunner(deviceService: deviceService)
    }
}
