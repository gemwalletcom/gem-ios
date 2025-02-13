// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import GRDB

struct AvatarValueRecord: Codable, FetchableRecord, PersistableRecord {
    static var databaseTableName: String { "avatar_type" }
    
    let walletId: String
    let avatarValue: AvatarValue
}

extension AvatarValueRecord: CreateTable {
    static func create(db: Database) throws {
        try db.create(table: Self.databaseTableName, ifNotExists: true) {
            $0.column(Columns.Avatar.walletId.name, .text)
                .primaryKey()
                .references(WalletRecord.databaseTableName, onDelete: .cascade)
            $0.column(Columns.Avatar.avatarValue.name, .jsonText)
        }
    }
}

extension AvatarValue {
    func mapToRecord(for walletId: String) -> AvatarValueRecord {
        AvatarValueRecord(
            walletId: walletId,
            avatarValue: self
        )
    }
}
