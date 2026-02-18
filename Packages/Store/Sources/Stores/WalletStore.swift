// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import Primitives

public struct WalletStore: Sendable {
    
    let db: DatabaseQueue
    
    public init(
        db: DB
    ) {
        self.db = db.dbQueue
    }
    
    public func nextWalletIndex() throws -> Int {
        return try db.read { db in
            let request = WalletRecord
                .select(max(WalletRecord.Columns.index))
            
            if let index = try Int.fetchOne(db, request) {
                return index + 1
            }
            return 1
        }
    }
    
    public func addWallet(_ wallet: Wallet) throws {
        let index = try nextWalletIndex()
        var record = wallet.record
        record.index = index
        record.order = index
        try db.write { db in
            try record.insert(db, onConflict: .ignore)
            for account in wallet.accounts {
                try account.record(for: wallet.id).upsert(db)
            }
        }
    }
    
    public func getWallet(id walletId: WalletId) throws -> Wallet? {
        try db.read { db in
            try WalletRecord
                .filter(WalletRecord.Columns.id == walletId.id)
                .including(all: WalletRecord.accounts)
                .asRequest(of: WalletRecordInfo.self)
                .fetchOne(db)?
                .mapToWallet()
        }
    }
    
    public func getWallets() throws -> [Wallet] {
        try db.read { db in
            try WalletRecord
                .including(all: WalletRecord.accounts)
                .asRequest(of: WalletRecordInfo.self)
                .fetchAll(db)
                .compactMap { $0.mapToWallet() }
        }
    }
    
    public func renameWallet(_ walletId: WalletId, name: String) throws {
        let _ = try db.write { db in
            let assignments = [
                WalletRecord.Columns.name.set(to: name),
                WalletRecord.Columns.updatedAt.set(to: Date.now)
            ]
            return try WalletRecord
                .filter(WalletRecord.Columns.id == walletId.id)
                .updateAll(db, assignments)
        }
    }
    
    @discardableResult
    public func deleteWallet(for walletId: WalletId) throws -> Bool {
        try db.write { db in
            try WalletRecord.deleteOne(db, key: walletId.id)
            try AccountRecord
                .filter(AccountRecord.Columns.walletId == walletId.id)
                .deleteAll(db)
            return true
        }
    }

    public func pinWallet(_ walletId: WalletId, value: Bool) throws {
        let _ = try db.write { db in
            return try WalletRecord
                .filter(WalletRecord.Columns.id == walletId.id)
                .updateAll(db, WalletRecord.Columns.isPinned.set(to: value))
        }
    }

    public func swapOrder(from: WalletId, to: WalletId) throws {
        guard
            let fromWallet = try getWallet(id: from),
            let toWallet = try getWallet(id: to) else {
            throw AnyError("Unable to locate wallets to swap order")
        }
        return try db.write { db in
            try WalletRecord
                .filter(WalletRecord.Columns.id == fromWallet.id)
                .updateAll(db, WalletRecord.Columns.order.set(to: toWallet.order))

            try WalletRecord
                .filter(WalletRecord.Columns.id == toWallet.id)
                .updateAll(db, WalletRecord.Columns.order.set(to: fromWallet.order))
        }
    }

    public func observer() -> SubscriptionsObserver {
        return SubscriptionsObserver(dbQueue: db)
    }
    
    public func setWalletAvatar(_ walletId: WalletId, path: String?) throws {
        let _ = try db.write { db in
            let assignments = [
                WalletRecord.Columns.imageUrl.set(to: path),
                WalletRecord.Columns.updatedAt.set(to: Date.now)
            ]
            return try WalletRecord
                .filter(WalletRecord.Columns.id == walletId.id)
                .updateAll(db, assignments)
        }
    }

    func setOrder(walletId: String, order: Int) throws {
        let _ = try db.write { db in
            try WalletRecord
                .filter(WalletRecord.Columns.id == walletId)
                .updateAll(db, WalletRecord.Columns.order.set(to: order))
        }
    }
}

extension WalletRecord {
    func mapToWallet() -> Wallet {
        return Wallet(
            id: id,
            externalId: externalId,
            name: name,
            index: index.asInt32,
            type: type,
            accounts: [],
            order: order.asInt32,
            isPinned: isPinned,
            imageUrl: imageUrl,
            source: source
        )
    }
}

extension Wallet {
    var record: WalletRecord {
        return WalletRecord(
            id: id,
            externalId: externalId,
            name: name,
            type: type,
            index: index.asInt,
            order: 0,
            isPinned: false,
            imageUrl: imageUrl,
            updatedAt: nil,
            source: source
        )
    }
}

extension Account {
    func record(for walletId: String) -> AccountRecord {
        return AccountRecord(
            walletId: walletId,
            chain: chain,
            address: address,
            extendedPublicKey: extendedPublicKey ?? "",
            index: 0,
            derivationPath: derivationPath
        )
    }
}
