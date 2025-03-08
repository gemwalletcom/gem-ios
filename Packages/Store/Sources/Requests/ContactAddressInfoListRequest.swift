// Copyright (c). Gem Wallet. All rights reserved.

import GRDBQuery
import GRDB
import Primitives
import Combine

public struct ContactAddressInfoListRequest: ValueObservationQueryable {
    public static var defaultValue: [ContactAddressInfo] { [] }
    
    private let chain: Chain
    
    public init(chain: Chain) {
        self.chain = chain
    }
    
    public func fetch(_ db: Database) throws -> [ContactAddressInfo] {
        do {
            let entities = try ContactAddressRecord
                .filter(Columns.ContactAddress.chain == chain.rawValue)
                .including(required: ContactAddressRecord.contact)
                .asRequest(of: ContactAddressInfoRecord.self)
                .fetchAll(db)
            
            return entities.map { $0.info }
        } catch {
            throw error
        }
    }
}
