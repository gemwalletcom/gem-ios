// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import GRDBQuery
import Combine
import Primitives

public struct PriceAlertsRequest: ValueObservationQueryable {
    public static var defaultValue: [PriceAlertData] { [] }
    
    public let assetId: AssetId?

    public init(assetId: AssetId? = nil) {
        self.assetId = assetId
    }

    public func fetch(_ db: Database) throws -> [PriceAlertData] {
        var request = AssetRecord
            .including(required: AssetRecord.priceAlert)
            .including(optional: AssetRecord.price)
            .order(AssetRecord.Columns.rank.desc)
            
        if let assetId = assetId {
            request = request.filter(AssetRecord.Columns.id == assetId.identifier)
        }
            
        return try request
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
