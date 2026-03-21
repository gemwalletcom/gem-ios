// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import FiatTransactionService
import Localization
import Primitives
import PrimitivesComponents
import Store

@Observable
@MainActor
public final class FiatTransactionsViewModel {
    private let service: FiatTransactionService
    let walletId: WalletId

    public let query: ObservableQuery<FiatTransactionsRequest>
    var transactions: [FiatTransactionInfo] { query.value }

    public init(walletId: WalletId, service: FiatTransactionService) {
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
            try await service.update(walletId: walletId)
        } catch {
            debugLog("FiatTransactionsViewModel fetch error: \(error)")
        }
    }
}
