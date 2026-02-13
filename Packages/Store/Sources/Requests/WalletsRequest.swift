// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import Primitives

public struct WalletsRequest: DatabaseQueryable {
    
    private let isPinned: Bool
    
    public init(isPinned: Bool) {
        self.isPinned = isPinned
    }
    
    public func fetch(_ db: Database) throws -> [Wallet] {
        try WalletRecord
            .including(all: WalletRecord.accounts)
            .filter(WalletRecord.Columns.isPinned == isPinned)
            .order(WalletRecord.Columns.order.asc)
            .asRequest(of: WalletRecordInfo.self)
            .fetchAll(db)
            .compactMap { $0.mapToWallet() }
    }
}

extension WalletsRequest: Equatable {}
