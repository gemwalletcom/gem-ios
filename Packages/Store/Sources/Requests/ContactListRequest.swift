// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDBQuery
import GRDB
import Primitives
import Combine

public struct ContactListRequest: ValueObservationQueryable {
    public static var defaultValue: [Contact] { [] }
        
    public init() {}
    
    public func fetch(_ db: Database) throws -> [Contact] {
        let request = ContactRecord
            .orderByPrimaryKey()
            .asRequest(of: ContactRecord.self)
        
        return try request
            .fetchAll(db)
            .map { $0.mapToContact() }
    }
}

