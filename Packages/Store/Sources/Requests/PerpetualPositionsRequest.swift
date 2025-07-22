// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import GRDBQuery
import Combine
import Primitives

public struct PerpetualPositionsRequest: ValueObservationQueryable {
    
    public static var defaultValue: [PerpetualPositionData] { [] }
    
    public var walletId: String
    
    public init(
        walletId: String
    ) {
        self.walletId = walletId
    }
    
    public func fetch(_ db: Database) throws -> [PerpetualPositionData] {
        let positions = try PerpetualPositionRecord
            .including(required: PerpetualPositionRecord.perpetual)
            .filter(PerpetualPositionRecord.Columns.walletId == walletId)
            .asRequest(of: PositionInfo.self)
            .fetchAll(db)
            .compactMap { try? $0.mapToPerpetualPositionData() }
        
        // Sort by position value (size * price) after fetching
        return positions.sorted { abs($0.position.size) * $0.perpetual.price > abs($1.position.size) * $1.perpetual.price }
    }
}
