// Copyright (c). Gem Wallet. All rights reserved.
import GRDB
import Primitives

public struct ContactAddressInfoRecord: FetchableRecord, Codable {
    let address: ContactAddressRecord
    let contact: ContactRecord
}

public extension ContactAddressInfoRecord {
    var info: ContactAddressInfo {
        ContactAddressInfo(
            address: address.address,
            contact: contact .contact
        )
    }
}
