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
            let chains = Self.compatibleChains(for: chain)
            addresses = addresses.filter(chains.map { $0.rawValue }.contains(ContactAddressRecord.Columns.chain))
        }

        return try ContactRecord
            .including(all: addresses)
            .order(ContactRecord.Columns.name.asc)
            .asRequest(of: ContactRecordInfo.self)
            .fetchAll(db)
            .map { $0.contactData }
    }

    private static func compatibleChains(for chain: Chain) -> [Chain] {
        if chain.isEvm {
            return Chain.allCases.filter { $0.isEvm }
        }
        return [chain]
    }
}
