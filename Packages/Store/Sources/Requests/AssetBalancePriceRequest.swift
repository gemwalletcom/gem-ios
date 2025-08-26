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
            .filter(AssetRecord.Columns.id == assetId.identifier)
            .including(optional: AssetRecord.price)
            .including(optional: AssetRecord.balance.filter(BalanceRecord.Columns.walletId == walletId))
            .asRequest(of: BalancePriceInfo.self)

        guard let record = try request.fetchOne(database) else {
            return nil
        }

        return AssetBalancePrice(
            balance: record.balance?.mapToBalance() ?? .zero,
            price: record.price?.mapToAssetPrice()
        )
    }
}
