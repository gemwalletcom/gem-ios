// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Primitives
import GRDBQuery
import Store
import Style

struct TransactionsScene: View {
    @Query<TransactionsRequest>
    private var transactions: [TransactionExtended]

    private let model: TransactionsViewModel

    init(
        model: TransactionsViewModel
    ) {
        self.model = model
        _transactions = Query(constant: model.request)
    }

    var body: some View {
        List {
            TransactionsList(transactions)
        }
        .refreshable {
            await fetch()
        }
        .overlay {
            // TODO: - migrate to StateEmptyView + Overlay, when we will have image
            if transactions.isEmpty {
                Text(Localized.Activity.EmptyState.message)
                    .textStyle(.body)
            }
        }
        .listSectionSpacing(.compact)
        .navigationTitle(model.title)
        .onAppear {
            onAppear()
        }
    }
}

// MARK: - Actions

extension TransactionsScene {
    private func onAppear() {
        Task {
            await fetch()
        }
    }
}

// MARK: - Effects

extension TransactionsScene {
    private func fetch() async {
        await model.fetch()
    }
}

// MARK: - Previews

#Preview {
    TransactionsScene(model: .init(walletId: .main, wallet: .main, type: .all, service: .main))
}
