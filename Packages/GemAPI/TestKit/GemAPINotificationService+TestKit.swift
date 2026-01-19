// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GemAPI
import Primitives

public final class GemAPINotificationServiceMock: GemAPINotificationService, @unchecked Sendable {
    private let notifications: [Primitives.Notification]

    public init(notifications: [Primitives.Notification] = []) {
        self.notifications = notifications
    }

    public func getNotifications(deviceId: String) async throws -> [Primitives.Notification] {
        notifications
    }

    public func markNotificationsRead(deviceId: String) async throws {}
}
