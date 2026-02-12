// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GemAPI
import Primitives

public final class GemAPINotificationServiceMock: GemAPINotificationService, @unchecked Sendable {
    private let notifications: [Primitives.InAppNotification]

    public init(notifications: [Primitives.InAppNotification] = []) {
        self.notifications = notifications
    }

    public func getNotifications(fromTimestamp: Int) async throws -> [Primitives.InAppNotification] {
        notifications
    }

    public func markNotificationsRead() async throws {}
}
