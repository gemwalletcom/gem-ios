// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import Primitives

public struct ContactsRequest: DatabaseQueryable {

    public let chain: Chain?

    public init(chain: Chain? = nil) {
        self.chain = chain
    }

    public func fetch(_ db: Database) throws -> [ContactData] {
        var addresses = ContactRecord.addresses
        if let chain {
            addresses = addresses.filter(ContactAddressRecord.Columns.chain == chain.rawValue)
        }

        return try ContactRecord
            .including(all: addresses)
            .order(ContactRecord.Columns.name.asc)
            .asRequest(of: ContactRecordInfo.self)
            .fetchAll(db)
            .map { $0.contactData }
    }
}
