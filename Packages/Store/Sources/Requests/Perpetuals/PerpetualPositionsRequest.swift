// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import GRDBQuery
import Combine
import Primitives

public struct PerpetualPositionsRequest: ValueObservationQueryable {
    
    public static var defaultValue: [PerpetualPositionData] { [] }
    
    public var walletId: String
    public var perpetualId: String?
    
    public init(
        walletId: String,
        perpetualId: String? = .none
    ) {
        self.walletId = walletId
        self.perpetualId = perpetualId
    }
    
    public func fetch(_ db: Database) throws -> [PerpetualPositionData] {
        var query = PerpetualRecord
            .including(required: PerpetualRecord.asset)
            .including(all: PerpetualRecord.positions
                .filter(PerpetualPositionRecord.Columns.walletId == walletId))
        
        if let perpetualId = perpetualId {
            query = query.filter(PerpetualRecord.Columns.id == perpetualId)
        }
        
        return try query
            .asRequest(of: PerpetualPositionsInfo.self)
            .fetchAll(db)
            .compactMap { $0.mapToPerpetualPositionData() }
            .sorted { lhs, rhs in
                let lhsValue = abs(lhs.position.size) * lhs.perpetual.price
                let rhsValue = abs(rhs.position.size) * rhs.perpetual.price
                return lhsValue > rhsValue
            }
    }
}
