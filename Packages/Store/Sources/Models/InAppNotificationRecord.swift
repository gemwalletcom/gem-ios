// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import GRDB

public struct InAppNotificationRecord: Codable, FetchableRecord, PersistableRecord {
    public static let databaseTableName: String = "notifications"

    public enum Columns {
        static let id = Column("id")
        static let walletId = Column("walletId")
        static let notificationType = Column("notificationType")
        static let isRead = Column("isRead")
        static let metadata = Column("metadata")
        static let createdAt = Column("createdAt")
    }

    public var id: String
    public var walletId: String
    public var notificationType: NotificationType
    public var isRead: Bool
    public var metadata: AnyCodableValue?
    public var createdAt: Date
}

extension InAppNotificationRecord: CreateTable {
    static func create(db: Database) throws {
        try db.create(table: Self.databaseTableName, ifNotExists: true) {
            $0.primaryKey(Columns.id.name, .text)
                .notNull()
                .indexed()
            $0.column(Columns.walletId.name, .text)
                .notNull()
                .indexed()
            $0.column(Columns.notificationType.name, .text)
                .notNull()
            $0.column(Columns.isRead.name, .boolean)
                .notNull()
                .defaults(to: false)
            $0.column(Columns.metadata.name, .jsonText)
            $0.column(Columns.createdAt.name, .date)
                .notNull()
                .indexed()
        }
    }
}

extension InAppNotificationRecord {
    func mapToNotification() -> Primitives.Notification {
        Primitives.Notification(
            walletId: walletId,
            notificationType: notificationType,
            isRead: isRead,
            metadata: metadata,
            createdAt: createdAt
        )
    }
}

extension Primitives.Notification {
    func record() -> InAppNotificationRecord {
        InAppNotificationRecord(
            id: "\(walletId)_\(notificationType.rawValue)_\(createdAt.timeIntervalSince1970)",
            walletId: walletId,
            notificationType: notificationType,
            isRead: isRead,
            metadata: metadata,
            createdAt: createdAt
        )
    }
}
