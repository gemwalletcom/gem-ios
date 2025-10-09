// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Formatters
import Store

@Observable
@MainActor
final class PerpetualsPreviewViewModel {
    
    private let currencyFormatter = CurrencyFormatter(type: .currency, currencyCode: Currency.usd.rawValue)
    
    var positions: [PerpetualPositionData] = []
    var walletBalance: WalletBalance = .zero
    
    var positionsRequest: PerpetualPositionsRequest
    var walletBalanceRequest: PerpetualWalletBalanceRequest
    
    init(walletId: WalletId) {
        self.positionsRequest = PerpetualPositionsRequest(walletId: walletId.id)
        self.walletBalanceRequest = PerpetualWalletBalanceRequest(walletId: walletId.id)
    }
    
    var tradePerpetualsSubtitle: String {
        currencyFormatter.string(walletBalance.total)
    }
    
    var hasNoPositions: Bool {
        positions.isEmpty
    }
    
    func updateWallet(walletId: WalletId) {
        positionsRequest = PerpetualPositionsRequest(walletId: walletId.id)
        walletBalanceRequest = PerpetualWalletBalanceRequest(walletId: walletId.id)
    }
}
