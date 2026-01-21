// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Combine
import GRDB
import GRDBQuery
import Primitives

public struct InAppNotificationsRequest: ValueObservationQueryable {
    public static var defaultValue: [Primitives.InAppNotification] { [] }

    public var walletId: String

    public init(walletId: String) {
        self.walletId = walletId
    }

    public func fetch(_ db: Database) throws -> [Primitives.InAppNotification] {
        try NotificationRecord
            .filter(NotificationRecord.Columns.walletId == walletId)
            .order(NotificationRecord.Columns.createdAt.desc)
            .fetchAll(db)
            .map { $0.mapToNotification() }
    }
}
