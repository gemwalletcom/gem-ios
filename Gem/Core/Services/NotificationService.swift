// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Combine

@Observable
class NotificationService {

    var notifications: [PushNotification] = []

    init() {

    }

    func clear() {
        notifications = []
    }

    func handleUserInfoOnLaunch(_ userInfo: [AnyHashable : Any]) {
        handleUserInfo(userInfo)
    }

    func handleUserInfo(_ userInfo: [AnyHashable : Any]) {
        do {
            let notification = try PushNotification(from: userInfo)
            notifications.append(notification)
        } catch {
            NSLog("handleUserInfo error \(error)")
        }
    }
}
