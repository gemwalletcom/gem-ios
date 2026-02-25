// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import Primitives

struct ContactRecordInfo: FetchableRecord, Codable {
    var contact: ContactRecord
    var addresses: [ContactAddressRecord]
}

extension ContactRecordInfo {
    var contactData: ContactData {
        ContactData(
            contact: contact.contact,
            addresses: addresses.map { $0.contactAddress }
        )
    }
}
