// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDBQuery
import GRDB
import Primitives
import Combine

public struct ContactAddressListRequest: ValueObservationQueryable {
    public static var defaultValue: [ContactAddress] { [] }
    
    private let contact: Contact?

    public init(contact: Contact?) {
        self.contact = contact
    }
    
    public func fetch(_ db: Database) throws -> [ContactAddress] {
        guard let contact else {
            return []
        }
        
        let request = ContactAddressRecord
            .filter(Columns.ContactAddress.contactId == contact.id.id)
            .asRequest(of: ContactAddressRecord.self)
        
        return try request
            .fetchAll(db)
            .compactMap { $0.mapToAddress(with: contact) }
    }
}
