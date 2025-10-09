// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import GRDBQuery
import Combine
import Primitives

public struct PerpetualsRequest: ValueObservationQueryable {
    static let defaultQueryLimit = 100
    public static var defaultValue: [PerpetualData] { [] }

    public let searchQuery: String

    public init(searchQuery: String = "") {
        self.searchQuery = searchQuery
    }

    public func fetch(_ db: Database) throws -> [PerpetualData] {
        var request = PerpetualRecord.including(required: PerpetualRecord.asset)

        if !searchQuery.isEmpty {
            request = request.filter(
                PerpetualRecord.Columns.name.like("%%\(searchQuery)%%") ||
                TableAlias(name: AssetRecord.databaseTableName)[AssetRecord.Columns.symbol].like("%%\(searchQuery)%%")
            )
        }

        return try request
            .order(PerpetualRecord.Columns.volume24h.desc)
            .limit(Self.defaultQueryLimit)
            .asRequest(of: PerpetualInfo.self)
            .fetchAll(db)
            .map { $0.mapToPerpetualData() }
    }
}
