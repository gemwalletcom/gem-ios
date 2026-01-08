// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import GRDBQuery
import Combine
import Primitives

public enum BalanceType: Sendable {
    case wallet
    case perpetual
}

public struct TotalValueRequest: ValueObservationQueryable {
    public static var defaultValue: Double { 0 }

    public var walletId: WalletId
    public var type: BalanceType

    public init(walletId: WalletId, balanceType: BalanceType) {
        self.walletId = walletId
        self.type = balanceType
    }

    public func fetch(_ db: Database) throws -> Double {
        switch type {
        case .wallet: try fetchWalletBalance(db)
        case .perpetual: try fetchPerpetualBalance(db)
        }
    }

    private func fetchWalletBalance(_ db: Database) throws -> Double {
        try AssetRecord
            .including(optional: AssetRecord.price)
            .including(optional: AssetRecord.balance)
            .joining(required: AssetRecord.balance
                .filter(BalanceRecord.Columns.walletId == walletId.id)
                .filter(BalanceRecord.Columns.isEnabled == true)
            )
            .asRequest(of: AssetRecordInfoMinimal.self)
            .fetchAll(db)
            .map { $0.totalFiatAmount }
            .reduce(0, +)
    }

    private func fetchPerpetualBalance(_ db: Database) throws -> Double {
        try AssetRecord
            .including(required: AssetRecord.balance)
            .filter(AssetRecord.Columns.type == AssetType.perpetual.rawValue)
            .joining(required: AssetRecord.balance
                .filter(BalanceRecord.Columns.walletId == walletId.id)
            )
            .asRequest(of: PerpetualAssetBalance.self)
            .fetchAll(db)
            .map { $0.totalFiatAmount }
            .reduce(0, +)
    }
}
