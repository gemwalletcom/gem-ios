// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Store
import GemstonePrimitives
import Preferences
import Components

@Observable
@MainActor
final class MainTabViewModel {
    let wallet: Wallet
    let transactionsQuery: ObservableQuery<TransactionsCountRequest>

    var transactions: Int { transactionsQuery.value }
    var isPresentingToastMessage: ToastMessage?

    init(wallet: Wallet) {
        self.wallet = wallet
        self.transactionsQuery = ObservableQuery(TransactionsCountRequest(walletId: wallet.walletId, state: .pending), initialValue: 0)
    }

    var walletId: WalletId { wallet.walletId }

    var isMarketEnabled: Bool {
        false //TODO: Disabled. Preferences.standard.isDeveloperEnabled && wallet.type == .multicoin
    }

    var isCollectionsEnabled: Bool {
        switch wallet.type {
        case .multicoin: true
        case .single, .privateKey, .view:
            wallet.accounts.first?.chain.isNFTSupported ?? false
        }
    }
}
