// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import GRDB

public struct NotificationRecord: Codable, FetchableRecord, PersistableRecord {
    public static let databaseTableName: String = "notifications"

    public enum Columns {
        static let id = Column("id")
        static let walletId = Column("walletId")
        static let readAt = Column("readAt")
        static let createdAt = Column("createdAt")
        static let item = Column("item")
    }

    public var id: String
    public var walletId: String
    public var readAt: Date?
    public var createdAt: Date
    public var item: CoreListItem
}

extension NotificationRecord: CreateTable {
    static func create(db: Database) throws {
        try db.create(table: Self.databaseTableName, ifNotExists: true) {
            $0.primaryKey(Columns.id.name, .text)
                .notNull()
            $0.column(Columns.walletId.name, .text)
                .notNull()
                .indexed()
                .references(WalletRecord.databaseTableName, onDelete: .cascade, onUpdate: .cascade)
            $0.column(Columns.readAt.name, .date)
            $0.column(Columns.createdAt.name, .date)
                .notNull()
                .indexed()
            $0.column(Columns.item.name, .jsonText)
                .notNull()
        }
    }
}

extension NotificationRecord {
    func mapToNotification() -> Primitives.InAppNotification {
        Primitives.InAppNotification(
            walletId: walletId,
            readAt: readAt,
            createdAt: createdAt,
            item: item
        )
    }
}

extension Primitives.InAppNotification {
    func record() -> NotificationRecord {
        NotificationRecord(
            id: item.id,
            walletId: walletId,
            readAt: readAt,
            createdAt: createdAt,
            item: item
        )
    }
}
