// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDBQuery
import GRDB
import Primitives
import Combine

public struct ContactAddressListRequest: ValueObservationQueryable {
    public static var defaultValue: [ContactAddress] { [] }
    
    private let contactId: ContactId
    
    public init(contactId: ContactId) {
        self.contactId = contactId
    }
    
    public func fetch(_ db: Database) throws -> [ContactAddress] {
        let request = ContactAddressRecord
            .filter(Columns.ContactAddress.contactId == contactId.id)
            .asRequest(of: ContactAddressRecord.self)
        
        return try request
            .fetchAll(db)
            .compactMap { $0.mapToAddress() }
    }
}
