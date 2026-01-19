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
        static let readAt = Column("readAt")
        static let createdAt = Column("createdAt")
    }

    public var id: String
    public var walletId: String
    public var notificationType: NotificationType
    public var isRead: Bool
    public var metadata: AnyCodableValue?
    public var readAt: Date?
    public var createdAt: Date
}

extension InAppNotificationRecord: CreateTable {
    static func create(db: Database) throws {
        try db.create(table: Self.databaseTableName, ifNotExists: true) {
            $0.primaryKey(Columns.id.name, .text)
                .notNull()
            $0.column(Columns.walletId.name, .text)
                .notNull()
                .indexed()
                .references(WalletRecord.databaseTableName, onDelete: .cascade)
            $0.column(Columns.notificationType.name, .text)
                .notNull()
            $0.column(Columns.isRead.name, .boolean)
                .notNull()
            $0.column(Columns.metadata.name, .jsonText)
            $0.column(Columns.readAt.name, .date)
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
            readAt: readAt,
            createdAt: createdAt
        )
    }
}

extension Primitives.Notification {
    func record(walletId: WalletId) -> InAppNotificationRecord {
        InAppNotificationRecord(
            id: "\(walletId.id)_\(notificationType.rawValue)_\(createdAt.timeIntervalSince1970)",
            walletId: walletId.id,
            notificationType: notificationType,
            isRead: isRead,
            metadata: metadata,
            readAt: readAt,
            createdAt: createdAt
        )
    }
}
