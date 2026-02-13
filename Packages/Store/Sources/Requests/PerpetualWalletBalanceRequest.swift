// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import Primitives

public struct PerpetualWalletBalanceRequest: DatabaseQueryable {

    private let totalValueRequest: TotalValueRequest

    public init(walletId: WalletId) {
        self.totalValueRequest = TotalValueRequest(walletId: walletId, balanceType: .perpetual)
    }
    
    public func fetch(_ db: Database) throws -> WalletBalance {
        try totalValueRequest.fetchWalletBalance(db)
    }
}

extension PerpetualWalletBalanceRequest: Equatable {}