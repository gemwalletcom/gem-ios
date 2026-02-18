// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Combine
import GRDB
import GRDBQuery
import Primitives

public struct ContactsRequest: ValueObservationQueryable {
    public static var defaultValue: [ContactData] { [] }

    public var chain: Chain?

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
