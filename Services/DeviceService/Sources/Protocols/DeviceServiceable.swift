// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public protocol DeviceServiceable: Sendable {
    func getDeviceId() throws -> String
    // returns same device ID as getDeviceId(), but making sure subscriptions has been updated.
    func getSubscriptionsDeviceId() async throws -> String
    func update() async throws
}
