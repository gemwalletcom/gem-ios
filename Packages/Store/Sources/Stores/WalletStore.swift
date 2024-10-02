// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import Primitives

public struct WalletStore: Sendable {
    
    let db: DatabaseQueue
    let preferences: Preferences
    
    public init(
        db: DB,
        preferences: Preferences = .standard
    ) {
        self.db = db.dbQueue
        self.preferences = preferences
    }
    
    public func nextWalletIndex() throws -> Int {
        return try db.read { db in
            let request = WalletRecord
                .select(max(Columns.Wallet.index))
            
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
    
    public func getWallet(id walletId: String) throws -> Wallet? {
        try db.read { db in
            try WalletRecord
                .filter(Columns.Wallet.id == walletId)
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
    
    public func renameWallet(_ walletId: String, name: String) throws {
        let _ = try db.write { db in
            return try WalletRecord
                .filter(Columns.Wallet.id == walletId)
                .updateAll(db, Columns.Wallet.name.set(to: name))
        }
    }
    
    
    @discardableResult
    public func deleteWallet(for id: String) throws -> Bool {
        try db.write { db in
            try WalletRecord.deleteOne(db, key: id)
            try AccountRecord
                .filter(Columns.Account.walletId == id)
                .deleteAll(db)
            return true
        }
    }

    public func pinWallet(_ walletId: String, value: Bool) throws {
        let _ = try db.write { db in
            return try WalletRecord
                .filter(Columns.Wallet.id == walletId)
                .updateAll(db, Columns.Wallet.isPinned.set(to: value))
        }
    }

    public func swapOrder(from: WalletId, to: WalletId) throws {
        guard 
            let fromWallet = try getWallet(id: from.id),
            let toWallet = try getWallet(id: to.id) else {
            throw AnyError("Unable to locate wallets to swap order")
        }
        return try db.write { db in
            try WalletRecord
                .filter(Columns.Wallet.id == fromWallet.id)
                .updateAll(db, Columns.Wallet.order.set(to: toWallet.order))

            try WalletRecord
                .filter(Columns.Wallet.id == toWallet.id)
                .updateAll(db, Columns.Wallet.order.set(to: fromWallet.order))
        }
    }

    public func observer() -> SubscriptionsObserver {
        return SubscriptionsObserver(dbQueue: db)
    }
}

extension WalletRecord {
    func mapToWallet() -> Wallet {
        return Wallet(
            id: id,
            name: name,
            index: index.asInt32,
            type: WalletType(rawValue: type)!,
            accounts: [],
            order: order.asInt32,
            isPinned: isPinned
        )
    }
}

extension Wallet {
    var record: WalletRecord {
        return WalletRecord(
            id: id,
            name: name,
            type: type.rawValue, 
            index: index.asInt,
            order: 0,
            isPinned: false
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
