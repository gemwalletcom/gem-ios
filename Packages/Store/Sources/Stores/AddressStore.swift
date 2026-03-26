// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import Primitives

public struct AddressStore: Sendable {
    
    private let db: DatabaseQueue
    
    public init(db: DB) {
        self.db = db.dbQueue
    }
    
    public func addAddressNames(_ addressNames: [AddressName]) throws {
        try db.write { db in
            for addressName in addressNames {
                try save(addressName: addressName, walletId: nil, db: db)
            }
        }
    }

    public func addWalletAddressName(wallet: Wallet, chain: Chain, address: String) throws {
        let addressName = AddressName(
            chain: chain,
            address: address,
            name: wallet.name,
            type: .internalWallet,
            status: .verified
        )

        try db.write { db in
            try save(addressName: addressName, walletId: wallet.id, db: db)
        }
    }
    
    public func getAddressName(chain: Chain, address: String) throws -> AddressName? {
        try db.read { db in
            try AddressRecord
                .filter(AddressRecord.Columns.chain == chain.rawValue)
                .filter(AddressRecord.Columns.address == address)
                .fetchOne(db)?
                .asPrimitive()
        }
    }
    
    // MARK: - Private
    
    private func save(addressName: AddressName, walletId: String?, db: Database) throws {
        try AddressRecord(
            chain: addressName.chain,
            address: addressName.address,
            walletId: walletId,
            name: addressName.name,
            type: addressName.type,
            status: addressName.status
        ).save(db, onConflict: .replace)
    }
}
