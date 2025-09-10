// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import GRDBQuery
import Combine
import Primitives

public struct PriceRequest: ValueObservationQueryable {
    public static var defaultValue: PriceData? { nil }

    public var assetId: AssetId

    public init(assetId: AssetId) {
        self.assetId = assetId
    }

    public func fetch(_ db: Database) throws -> PriceData? {
        try AssetRecord
            .including(optional: AssetRecord.price)
            .including(all: AssetRecord.priceAlerts)
            .including(all: AssetRecord.links)
            .filter(AssetRecord.Columns.id == assetId.identifier)
            .asRequest(of: PriceRecordInfo.self)
            .fetchOne(db)
            .map { $0.priceData }
    }
}
