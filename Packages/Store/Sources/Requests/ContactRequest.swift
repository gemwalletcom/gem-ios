// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDBQuery
import GRDB
import Primitives
import Combine

public struct ContactListRequest: ValueObservationQueryable {
    public static var defaultValue: [Contact] { [] }
    
    private let searchQuery: String?
    
    public init(
        searchQuery: String?
    ) {
        self.searchQuery = searchQuery
    }
    
    public func fetch(_ db: Database) throws -> [Contact] {
        var request = ContactRecord
            .orderByPrimaryKey()
            .distinct()
            .asRequest(of: ContactRecord.self)
        
        if let searchQuery {
            request = request.filter(
                Columns.Contact.name.like("%%\(searchQuery)%%")
            )
        }
        
        return try request
            .fetchAll(db)
            .map { $0.contact }
    }
}

