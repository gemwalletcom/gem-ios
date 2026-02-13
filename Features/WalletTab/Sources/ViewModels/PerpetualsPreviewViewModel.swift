// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Formatters
import Store

@Observable
@MainActor
final class PerpetualsPreviewViewModel {
    
    private let currencyFormatter = CurrencyFormatter(type: .currency, currencyCode: Currency.usd.rawValue)

    let positionsQuery: ObservableQuery<PerpetualPositionsRequest>
    let walletBalanceQuery: ObservableQuery<PerpetualWalletBalanceRequest>

    var positions: [PerpetualPositionData] { positionsQuery.value }
    var walletBalance: WalletBalance { walletBalanceQuery.value }

    init(walletId: WalletId) {
        self.positionsQuery = ObservableQuery(PerpetualPositionsRequest(walletId: walletId), initialValue: [])
        self.walletBalanceQuery = ObservableQuery(PerpetualWalletBalanceRequest(walletId: walletId), initialValue: .zero)
    }
    
    var tradePerpetualsSubtitle: String {
        currencyFormatter.string(walletBalance.total)
    }
    
    var hasNoPositions: Bool {
        positions.isEmpty
    }
    
    func updateWallet(walletId: WalletId) {
        positionsQuery.request = PerpetualPositionsRequest(walletId: walletId)
        walletBalanceQuery.request = PerpetualWalletBalanceRequest(walletId: walletId)
    }
}
