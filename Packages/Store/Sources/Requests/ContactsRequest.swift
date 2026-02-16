// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Combine
import GRDB
import GRDBQuery
import Primitives

public struct ContactsRequest: ValueObservationQueryable {
    public static var defaultValue: [Contact] { [] }

    public var chain: Chain?

    public init(chain: Chain? = nil) {
        self.chain = chain
    }

    public func fetch(_ db: Database) throws -> [Contact] {
        var request = ContactRecord.order(ContactRecord.Columns.name.asc)
        if let chain {
            let chains = Self.compatibleChains(for: chain)
            request = request.filter(chains.map { $0.rawValue }.contains(ContactRecord.Columns.chain))
        }
        return try request.fetchAll(db).map { $0.mapToContact() }
    }

    private static func compatibleChains(for chain: Chain) -> [Chain] {
        let evmChains = EVMChain.allCases.compactMap { Chain(rawValue: $0.rawValue) }
        if evmChains.contains(chain) {
            return evmChains
        }
        return [chain]
    }
}
