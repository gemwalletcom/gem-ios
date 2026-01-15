// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Combine
import GRDB
import GRDBQuery
import Primitives

public struct InAppNotificationsRequest: ValueObservationQueryable {
    public static var defaultValue: [Primitives.Notification] { [] }

    public var walletIdType: String

    public init(walletIdType: String) {
        self.walletIdType = walletIdType
    }

    public func fetch(_ db: Database) throws -> [Primitives.Notification] {
        try InAppNotificationRecord
            .filter(InAppNotificationRecord.Columns.walletId == walletIdType)
            .order(InAppNotificationRecord.Columns.createdAt.desc)
            .fetchAll(db)
            .map { $0.mapToNotification() }
    }
}
