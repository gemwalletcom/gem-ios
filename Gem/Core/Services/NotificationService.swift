// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

@Observable
class NotificationService {

    var notifications: [PushNotification] = []

    init() {

    }

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
