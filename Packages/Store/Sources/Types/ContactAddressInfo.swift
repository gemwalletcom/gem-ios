// Copyright (c). Gem Wallet. All rights reserved.
import GRDB
import Primitives

public struct ContactAddressInfo: FetchableRecord, Codable {
    let address: ContactAddressRecord
    let contact: ContactRecord
    
    public init(row: Row) throws {
        address = try ContactAddressRecord(row: row)
        contact = row["contact"]
    }
}

public extension ContactAddressInfo {
    func mapToData() -> ContactAddressData {
        let contact = contact.mapToContact()
        return ContactAddressData(
            address: address.mapToAddress(with: contact),
            contact: contact
        )
    }
}
