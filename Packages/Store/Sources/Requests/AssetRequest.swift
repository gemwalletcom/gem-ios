// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import GRDBQuery
import Combine
import Primitives

public struct AssetRequest: Queryable {
    
    public static var defaultValue: AssetData { AssetData.empty }
    
    public let walletId: String
    public var assetId: String

    public init(
        walletId: String,
        assetId: String
    ) {
        self.walletId = walletId
        self.assetId = assetId
    }
    
    public func publisher(in dbQueue: DatabaseQueue) -> AnyPublisher<AssetData, Error> {
        ValueObservation
            .tracking { db in try fetch(db) }
            .publisher(in: dbQueue, scheduling: .immediate)
            .eraseToAnyPublisher()
    }
    
    private func fetch(_ db: Database) throws -> AssetData {
        return try AssetRecord
            .including(optional: AssetRecord.price)
            .including(optional: AssetRecord.balance)
            .including(optional: AssetRecord.details)
            .including(optional: AssetRecord.account)
            .filter(literal:
                SQL(stringLiteral: String(format:"%@.walletId = '%@'", AssetBalanceRecord.databaseTableName, walletId))
            )
            .filter(literal:
                SQL(stringLiteral: String(format:"%@.walletId = '%@'", AccountRecord.databaseTableName, walletId))
            )
            .filter(Columns.Asset.id == assetId)
            .order(literal:
                SQL(stringLiteral: String(format: "%@.fiatValue DESC", AssetBalanceRecord.databaseTableName))
            )
            .asRequest(of: AssetRecordInfo.self)
            .fetchOne(db)
            .map { $0.assetData }!
    }
}

extension AssetData {
    static let empty: AssetData = {
        return AssetData(
            asset: Asset(id: .init(chain: .bitcoin, tokenId: .none), name: "", symbol: "", decimals: 0, type: .native),
            balance: Balance.zero,
            account: Account(chain: .bitcoin, address: "", derivationPath: "", extendedPublicKey: .none),
            price: .none,
            details: .none,
            metadata: AssetMetaData(
                isEnabled: false,
                isBuyEnabled: false,
                isSwapEnabled: false,
                isStakeEnabled: false,
                isPinned: false
            )
        )
    }()
}
