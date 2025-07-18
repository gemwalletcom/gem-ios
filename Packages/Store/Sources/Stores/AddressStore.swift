// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import Primitives

public struct AddressStore: Sendable {
    
    let db: DatabaseQueue
    
    public init(db: DB) {
        self.db = db.dbQueue
    }
    
    public func addAddressNames(_ addressNames: [AddressName]) throws {
        try db.write { db in
            for addressName in addressNames {
                try AddressRecord(
                    chain: addressName.chain,
                    address: addressName.address,
                    name: addressName.name
                ).save(db, onConflict: .replace)
            }
        }
    }
    
    public func deleteAddress(chain: Chain, address: String) throws -> Int {
        try db.write { db in
            try AddressRecord
                .filter(AddressRecord.Columns.chain == chain.rawValue)
                .filter(AddressRecord.Columns.address == address)
                .deleteAll(db)
        }
    }
}
