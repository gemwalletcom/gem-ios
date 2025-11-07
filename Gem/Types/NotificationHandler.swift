// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

@Observable
final class NotificationHandler: Sendable {
    @MainActor
    var notifications: [PushNotification] = []

    init() {}
}

@MainActor
extension NotificationHandler {
    func clear() {
        notifications = []
    }

    func notify(notification: PushNotification) {
        notifications.append(notification)
    }

    func handleUserInfo(_ userInfo: [AnyHashable : Any]) {
        do {
            notify(notification: try PushNotification(from: userInfo))
        } catch {
            #debugLog("handleUserInfo error \(error)")
        }
    }
}
