// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import DeviceService

public actor DeviceServiceMock: DeviceServiceable {
    public private(set) var updateCallCount = 0
    
    public init() {}

    public func update() async throws {
        updateCallCount += 1
    }
    
    public func getDeviceId() async throws -> String { .empty }
}
