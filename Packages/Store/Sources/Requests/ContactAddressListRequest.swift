// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDBQuery
import GRDB
import Primitives
import Combine

public struct ContactAddressListRequest: ValueObservationQueryable {
    public static var defaultValue: [ContactAddress] { [] }
    
    private let contactId: ContactId?
    private let chain: Chain?
    private let searchQuery: String?
    
    public init(
        contactId: ContactId?,
        chain: Chain?,
        searchQuery: String?
    ) {
        self.contactId = contactId
        self.chain = chain
        self.searchQuery = searchQuery
    }
    
    public func fetch(_ db: Database) throws -> [ContactAddress] {
        var request = ContactAddressRecord
            .orderByPrimaryKey()
            .distinct()
            .asRequest(of: ContactAddressRecord.self)
        
        if let contactId {
            request = request.filter(Columns.ContactAddress.contactId == contactId.id)
        }
        
        if let chain {
            request = request.filter(Columns.ContactAddress.chain == chain.rawValue)
        }
        
        if let searchQuery {
            request = request.filter(
                Columns.ContactAddress.value.like("%%\(searchQuery)%%")
            )
        }
        
        return try request
            .fetchAll(db)
            .compactMap { $0.address }
    }
}
