// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import Primitives

extension TotalValueRequest {
    func fetchWalletBalance(_ db: Database) throws -> WalletBalance {
        guard type == .perpetual else {
            throw NSError(domain: "TotalValueRequest", code: 0, userInfo: [NSLocalizedDescriptionKey: "fetchWalletBalance only works with perpetual balance type"])
        }
        
        let perpetualBalances = try AssetRecord
            .including(required: AssetRecord.balance)
            .filter(AssetRecord.Columns.type == AssetType.perpetual.rawValue)
            .joining(required: AssetRecord.balance
                .filter(BalanceRecord.Columns.walletId == walletId.id)
            )
            .asRequest(of: PerpetualAssetBalance.self)
            .fetchAll(db)
        
        let perpetualTotal = perpetualBalances
            .map { $0.totalFiatAmount }
            .reduce(0, +)
        
        let perpetualAvailable = perpetualBalances
            .map { $0.balance.availableAmount }
            .reduce(0, +)
        
        return WalletBalance(total: perpetualTotal, available: perpetualAvailable)
    }
}