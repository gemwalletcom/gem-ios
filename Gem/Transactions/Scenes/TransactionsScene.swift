// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Primitives
import GRDBQuery
import Store
import Style

struct TransactionsScene: View {
    @Environment(\.db) private var DB

    @Query<TransactionsRequest>
    private var transactions: [TransactionExtended]

    private let model: TransactionsViewModel

    init(
        model: TransactionsViewModel
    ) {
        self.model = model
        _transactions = Query(constant: model.request, in: \.db.dbQueue)
    }

    var body: some View {
        List {
            TransactionsList(transactions)
        }
        .refreshable {
            onRefresh()
        }
        .overlay {
            // TODO: - migrate to StateEmptyView + Overlay, when we will have image
            if transactions.isEmpty {
                Text(Localized.Activity.EmptyState.message)
                    .textStyle(.body)
            }
        }
        .navigationTitle(model.title)
        .navigationDestination(for: TransactionExtended.self) { transaction in
            TransactionScene(
                input: TransactionSceneInput(transactionId: transaction.id, walletId: model.walletId)
            )
        }
        .onAppear {
            onAppear()
        }
    }
}

// MARK: - Actions

extension TransactionsScene {
    private func onAppear() {
        fetch()
    }

    private func onRefresh() {
        fetch()
    }
}

// MARK: - Effects

extension TransactionsScene {
    private func fetch() {
        Task {
            await model.fetch()
        }
    }
}

// MARK: - Previews

#Preview {
    TransactionsScene(model: .init(walletId: .main, type: .all, service: .main))
}
