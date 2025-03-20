// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDBQuery
import GRDB
import Primitives
import Combine

public struct ContactListRequest: ValueObservationQueryable {
    public static var defaultValue: [Contact] { [] }
    
    public init() { }
    
    public func fetch(_ db: Database) throws -> [Contact] {
        do {
            return try ContactRecord
                .orderByPrimaryKey()
                .asRequest(of: ContactRecord.self)
                .fetchAll(db)
                .map { $0.mapToContact() }
        } catch {
            throw error
        }
    }
}
