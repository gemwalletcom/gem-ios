// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import GRDBQuery
import Combine
import Primitives

public struct AssetRequestOptional: ValueObservationQueryable {
    public static var defaultValue: AssetData? = .none
    
    public enum AssetRequestType: Sendable {
        case pay
        case receive
    }
    
    public var assetId: String?
    private let walletId: String
    private let type: AssetRequestType

    public init(
        walletId: String,
        assetId: String?,
        type: AssetRequestType
    ) {
        self.walletId = walletId
        self.assetId = assetId
        self.type = type
    }
    
    public func fetch(_ db: Database) throws -> AssetData? {
        var request = AssetRecord
            .including(optional: AssetRecord.price)
            .including(optional: AssetRecord.balance)
            .including(optional: AssetRecord.account)
            .including(optional: AssetRecord.priceAlert)
            .joining(optional: AssetRecord.balance.filter(Columns.Balance.walletId == walletId))
            .joining(optional: AssetRecord.account.filter(Columns.Account.walletId == walletId))
            .asRequest(of: AssetRecordInfo.self)
        
        applyTypeFilter(&request)

        return try request
            .fetchOne(db)
            .map { $0.assetData }
    }
    
    private func applyTypeFilter(_ request: inout QueryInterfaceRequest<AssetRecordInfo>) {
        switch type {
        case .pay:
            if assetId == nil {
                request = request
                    .order((
                        TableAlias(name: AssetBalanceRecord.databaseTableName)[Columns.Balance.totalAmount] * (TableAlias(name: PriceRecord.databaseTableName)[Columns.Price.price] ?? 0)).desc
                    )
            } else {
                request = request
                    .filter(Columns.Asset.id == assetId)
            }
        case .receive:
            request = request
                .filter(Columns.Asset.id == assetId)
        }
    }
}
