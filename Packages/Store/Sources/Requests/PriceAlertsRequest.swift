// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import GRDBQuery
import Combine
import Primitives

public struct PriceAlertsRequest: ValueObservationQueryable {
    public static var defaultValue: [PriceAlertData] { [] }

    public init() {}

    public func fetch(_ db: Database) throws -> [PriceAlertData] {
        try AssetRecord
            .including(required: AssetRecord.priceAlert)
            .including(optional: AssetRecord.price)
            .asRequest(of: PriceAlertInfo.self)
            .fetchAll(db)
            .map { $0.data }
    }
}

public struct PriceAlertInfo: FetchableRecord, Codable {
    public var asset: AssetRecord
    public var price: PriceRecord?
    public var priceAlert: PriceAlertRecord
}

extension PriceAlertInfo {
    var data: PriceAlertData {
        PriceAlertData(
            asset: asset.mapToAsset(),
            price: price?.mapToPrice(),
            priceAlert: priceAlert.map()
        )
    }
}

extension PriceAlertData: Identifiable {
    public var id: String { asset.id.identifier }
}
