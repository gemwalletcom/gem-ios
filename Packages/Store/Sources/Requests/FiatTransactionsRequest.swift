// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import Primitives

public struct FiatTransactionsRequest: DatabaseQueryable {

    public let walletId: WalletId
    public let assetId: AssetId

    public init(walletId: WalletId, assetId: AssetId) {
        self.walletId = walletId
        self.assetId = assetId
    }

    public func fetch(_ db: Database) throws -> [FiatTransaction] {
        try FiatTransactionRecord
            .filter(FiatTransactionRecord.Columns.walletId == walletId.id)
            .filter(FiatTransactionRecord.Columns.assetId == assetId.identifier)
            .fetchAll(db)
            .map { $0.fiatTransaction }
    }
}
