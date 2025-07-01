// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import DeviceService

public struct DeviceServiceMock: DeviceServiceable {
    
    public init() {}

    public func update() async throws {
    }
    
    public func getDeviceId() throws -> String { .empty }
    public func getSubscriptionsDeviceId() async throws -> String {
        try self.getDeviceId()
    }
}
