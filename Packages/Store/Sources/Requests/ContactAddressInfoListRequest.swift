// Copyright (c). Gem Wallet. All rights reserved.

import GRDBQuery
import GRDB
import Primitives
import Combine

public struct ContactAddressInfoListRequest: ValueObservationQueryable {
    public static var defaultValue: [ContactAddressData] { [] }
    
    private let chain: Chain
    
    public init(chain: Chain) {
        self.chain = chain
    }
    
    public func fetch(_ db: Database) throws -> [ContactAddressData] {
        do {
            return try ContactAddressRecord
                .filter(Columns.ContactAddress.chain == chain.rawValue)
                .including(required: ContactAddressRecord.contact)
                .asRequest(of: ContactAddressInfo.self)
                .fetchAll(db)
                .map { $0.mapToData() }
        } catch {
            throw error
        }
    }
}
