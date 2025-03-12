// Copyright (c). Gem Wallet. All rights reserved.
import GRDB
import Primitives

public struct ContactAddressInfoRecord: FetchableRecord, Codable {
    let address: ContactAddressRecord
    let contact: ContactRecord
    
    public init(row: Row) throws {
        address = try ContactAddressRecord(row: row)
        contact = row["contact"]
    }
}

public extension ContactAddressInfoRecord {
    func mapToInfo() -> ContactAddressInfo {
        ContactAddressInfo(
            address: address.mapToAddress(),
            contact: contact.mapToContact()
        )
    }
}
