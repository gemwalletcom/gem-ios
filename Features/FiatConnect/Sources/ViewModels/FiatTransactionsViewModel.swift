// Copyright (c). Gem Wallet. All rights reserved.

import Components
import Foundation
import FiatService
import Localization
import Primitives
import PrimitivesComponents
import Store

@Observable
@MainActor
public final class FiatTransactionsViewModel {
    private let service: FiatService
    let walletId: WalletId

    public let query: ObservableQuery<FiatTransactionsRequest>
    var transactions: [FiatTransactionInfo] { query.value }

    var sections: [ListSection<FiatTransactionInfo>] {
        DateSectionBuilder(items: transactions, dateKeyPath: \.transaction.createdAt).build()
    }

    public init(walletId: WalletId, service: FiatService) {
        self.walletId = walletId
        self.service = service
        self.query = ObservableQuery(FiatTransactionsRequest(walletId: walletId), initialValue: [])
    }

    var title: String { Localized.Activity.title }

    var emptyContentModel: EmptyContentTypeViewModel {
        EmptyContentTypeViewModel(type: .activity(isViewOnly: false))
    }

    func fetch() async {
        do {
            try await service.updateTransactions(walletId: walletId)
        } catch {
            debugLog("FiatTransactionsViewModel fetch error: \(error)")
        }
    }
}
