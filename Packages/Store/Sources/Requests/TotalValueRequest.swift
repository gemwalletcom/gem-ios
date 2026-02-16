// Copyright (c). Gem Wallet. All rights reserved.

import GRDB
import GRDBQuery
import Combine
import Primitives

public enum BalanceType: Sendable {
    case wallet
    case perpetual
}

public struct TotalValueRequest: ValueObservationQueryable {
    public static var defaultValue: TotalFiatValue { .zero }

    public var walletId: WalletId
    public var type: BalanceType

    public init(walletId: WalletId, balanceType: BalanceType) {
        self.walletId = walletId
        self.type = balanceType
    }

    public func fetch(_ db: Database) throws -> TotalFiatValue {
        switch type {
        case .wallet: try fetchWalletBalance(db)
        case .perpetual: try fetchPerpetualBalance(db)
        }
    }

    private func fetchWalletBalance(_ db: Database) throws -> TotalFiatValue {
        let (total, pnl) = try AssetRecord
            .including(optional: AssetRecord.price)
            .including(optional: AssetRecord.balance)
            .joining(required: AssetRecord.balance
                .filter(BalanceRecord.Columns.walletId == walletId.id)
                .filter(BalanceRecord.Columns.isEnabled == true)
            )
            .asRequest(of: AssetRecordInfoMinimal.self)
            .fetchAll(db)
            .reduce((0.0, 0.0)) { result, record in
                guard let price = record.price else { return result }
                let fiat = record.balance.totalAmount * price.price
                let pnl = PriceChangeCalculator.calculate(.amount(percentage: price.priceChangePercentage24h, value: fiat))
                return (result.0 + fiat, result.1 + pnl)
            }
        return TotalFiatValue(
            value: total,
            pnlAmount: pnl,
            pnlPercentage: PriceChangeCalculator.calculate(.percentage(from: total - pnl, to: total))
        )
    }

    private func fetchPerpetualBalance(_ db: Database) throws -> TotalFiatValue {
        let total = try AssetRecord
            .including(required: AssetRecord.balance)
            .filter(AssetRecord.Columns.type == AssetType.perpetual.rawValue)
            .joining(required: AssetRecord.balance
                .filter(BalanceRecord.Columns.walletId == walletId.id)
            )
            .asRequest(of: PerpetualAssetBalance.self)
            .fetchAll(db)
            .reduce(0.0) { $0 + $1.totalFiatAmount }
        return TotalFiatValue(value: total, pnlAmount: 0, pnlPercentage: 0)
    }
}
