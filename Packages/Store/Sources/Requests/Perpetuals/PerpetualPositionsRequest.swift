// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import Primitives

public struct PerpetualPositionsRequest: DatabaseQueryable {

    public var walletId: WalletId
    public var filter: PositionsRequestFilter?
    public var searchQuery: String

    public init(
        walletId: WalletId,
        filter: PositionsRequestFilter? = nil,
        searchQuery: String = ""
    ) {
        self.walletId = walletId
        self.filter = filter
        self.searchQuery = searchQuery
    }

    public func fetch(_ db: Database) throws -> [PerpetualPositionData] {
        var query = PerpetualRecord
            .including(required: PerpetualRecord.asset)
            .including(all: PerpetualRecord.positions
                .filter(PerpetualPositionRecord.Columns.walletId == walletId.id))

        switch filter {
        case .perpetualId(let perpetualId):
            query = query.filter(PerpetualRecord.Columns.id == perpetualId)
        case .assetId(let assetId):
            query = query.filter(PerpetualRecord.Columns.assetId == assetId.identifier)
        case .none:
            break
        }

        if !searchQuery.isEmpty {
            query = query.filter(
                PerpetualRecord.Columns.name.like("%%\(searchQuery)%%") ||
                PerpetualRecord.Columns.identifier.like("%%\(searchQuery)%%") ||
                TableAlias(name: AssetRecord.databaseTableName)[AssetRecord.Columns.name].like("%%\(searchQuery)%%") ||
                TableAlias(name: AssetRecord.databaseTableName)[AssetRecord.Columns.symbol].like("%%\(searchQuery)%%")
            )
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

extension PerpetualPositionsRequest: Equatable {}
