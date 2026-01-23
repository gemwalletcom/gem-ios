// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import Primitives

public struct InAppNotificationStore: Sendable {
    let db: DatabaseQueue

    public init(db: DB) {
        self.db = db.dbQueue
    }

    public func addNotifications(_ notifications: [InAppNotification]) throws {
        try db.write { db in
            for notification in notifications {
                try notification.record().upsert(db)
            }
        }
    }
}
