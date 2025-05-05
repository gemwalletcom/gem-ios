// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

@Observable
final class NotificationService: Sendable {
    @MainActor
    var notifications: [PushNotification] = []

    init() {}
}

@MainActor
extension NotificationService {
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
            NSLog("handleUserInfo error \(error)")
        }
    }
}
