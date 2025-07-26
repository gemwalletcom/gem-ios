// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import GRDBQuery
import Combine
import Primitives

public struct PerpetualsRequest: ValueObservationQueryable {
    
    public static var defaultValue: [PerpetualData] { [] }
    
    public init() {}
    
    public func fetch(_ db: Database) throws -> [PerpetualData] {
        return try PerpetualRecord
            .including(required: PerpetualRecord.asset)
            .order(PerpetualRecord.Columns.volume24h.desc)
            .limit(10)
            .asRequest(of: PerpetualInfo.self)
            .fetchAll(db)
            .map { $0.mapToPerpetualData() }
    }
}
