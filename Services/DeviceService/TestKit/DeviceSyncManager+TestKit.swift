// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import DeviceService

public extension DeviceSyncManager {
    static func mock(deviceService: DeviceService = .mock()) -> DeviceSyncManager {
        DeviceSyncManager(deviceService: deviceService)
    }
}
