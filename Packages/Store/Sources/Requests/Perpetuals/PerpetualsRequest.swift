// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import GRDBQuery
import Combine
import Primitives

public struct PerpetualsRequest: ValueObservationQueryable {
    
    public static var defaultValue: [Perpetual] { [] }
    
    public init() {}
    
    public func fetch(_ db: Database) throws -> [Perpetual] {
        return try PerpetualRecord
            .order(PerpetualRecord.Columns.volume24h.desc)
            .fetchAll(db)
            .map { $0.mapToPerpetual() }
    }
}
