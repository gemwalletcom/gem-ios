// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import Primitives

public struct WalletRequest: DatabaseQueryable {
    public var walletId: WalletId

    public init(walletId: WalletId) {
        self.walletId = walletId
    }

    public func fetch(_ db: Database) throws -> Wallet? {
        try WalletRecord
            .including(all: WalletRecord.accounts)
            .asRequest(of: WalletRecordInfo.self)
            .filter(WalletRecord.Columns.id == walletId.id)
            .fetchOne(db)?
            .mapToWallet()
    }
}

extension WalletRequest: Equatable {}
