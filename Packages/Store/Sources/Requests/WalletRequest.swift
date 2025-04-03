// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import GRDBQuery
import Combine
import Primitives

public struct WalletRequest: ValueObservationQueryable {
    public static var defaultValue: Wallet? { .none }
    public var walletId: String

    public init(walletId: String) {
        self.walletId = walletId
    }

    public func fetch(_ db: Database) throws -> Wallet? {
        try WalletRecord
            .including(all: WalletRecord.accounts)
            .asRequest(of: WalletRecordInfo.self)
            .filter(Columns.Wallet.id == walletId)
            .fetchOne(db)?
            .mapToWallet()
    }
}
