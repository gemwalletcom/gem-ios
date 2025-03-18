// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import GRDBQuery
import Combine
import Primitives

public struct PriceRequest: ValueObservationQueryable {
    public static var defaultValue: PriceData { fatalError() }

    public var assetId: String

    public init(assetId: String) {
        self.assetId = assetId
    }

    public func fetch(_ db: Database) throws -> PriceData {
        try AssetRecord
            .including(optional: AssetRecord.price)
            .including(all: AssetRecord.priceAlerts)
            .including(all: AssetRecord.links)
            .filter(Columns.Asset.id == assetId)
            .asRequest(of: PriceRecordInfo.self)
            .fetchOne(db)
            .map { $0.priceData }!
    }
}
