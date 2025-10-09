// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GRDB
import GRDBQuery
import Combine
import Primitives

public struct PerpetualWalletBalanceRequest: ValueObservationQueryable {
    public static var defaultValue: WalletBalance { .zero }
    
    private let totalValueRequest: TotalValueRequest
    
    public init(walletId: String) {
        self.totalValueRequest = TotalValueRequest(walletId: walletId, balanceType: .perpetual)
    }
    
    public func fetch(_ db: Database) throws -> WalletBalance {
        try totalValueRequest.fetchWalletBalance(db)
    }
}