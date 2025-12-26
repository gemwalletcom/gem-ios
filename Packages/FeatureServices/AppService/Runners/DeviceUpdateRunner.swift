// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import DeviceService
import Primitives

public struct DeviceUpdateRunner: OnstartAsyncRunnable {
    private let deviceService: DeviceService

    public init(deviceService: DeviceService) {
        self.deviceService = deviceService
    }

    public func run(config: ConfigResponse?) async throws {
        try await deviceService.update()
    }
}
