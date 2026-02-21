// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import Primitives

public struct PriceAlertsRequest: DatabaseQueryable {
    
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

struct PriceAlertInfo: FetchableRecord, Codable {
    var asset: AssetRecord
    var price: PriceRecord?
    var priceAlert: PriceAlertRecord
}

extension PriceAlertsRequest: Equatable {}

extension PriceAlertInfo {
    var data: PriceAlertData {
        PriceAlertData(
            asset: asset.mapToAsset(),
            price: price?.mapToPrice(),
            priceAlert: priceAlert.map()
        )
    }
}
