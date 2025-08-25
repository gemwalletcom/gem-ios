// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import GRDBQuery
import Combine
import Primitives

public struct AssetBalancePriceRequest: ValueObservationQueryable {
    public static var defaultValue: AssetBalancePrice? { nil }

    private let assetId: AssetId
    private let walletId: String

    public init(
        walletId: String,
        assetId: AssetId
    ) {
        self.walletId = walletId
        self.assetId = assetId
    }

    public func fetch(_ database: Database) throws -> AssetBalancePrice? {
        struct BalancePriceInfo: FetchableRecord, Codable {
            var asset: AssetRecord
            var balance: BalanceRecord?
            var price: PriceRecord?
        }
        
        let request = AssetRecord
            .including(optional: AssetRecord.balance)
            .including(optional: AssetRecord.price)
            .joining(optional: AssetRecord.balance.filter(BalanceRecord.Columns.walletId == walletId))
            .filter(AssetRecord.Columns.id == assetId.identifier)
            .asRequest(of: BalancePriceInfo.self)

        guard let record = try request.fetchOne(database) else {
            return nil
        }



        return AssetBalancePrice(
            assetId: record.asset.mapToAsset().id,
            balance: record.balance?.mapToBalance() ?? .zero,
            price: record.price?.mapToAssetPrice()
        )
    }
}
