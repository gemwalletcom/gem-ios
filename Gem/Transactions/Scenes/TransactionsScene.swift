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
        .overlay {
            // TODO: - migrate to StateEmptyView + Overlay, when we will have image
            if transactions.isEmpty {
                Text(Localized.Activity.EmptyState.message)
                    .textStyle(.body)
            }
        }
        .refreshable {
            onDataRefresh()
        }
        .navigationTitle(model.title)
        .navigationDestination(for: TransactionExtended.self) { transaction in
            TransactionScene(
                input: TransactionSceneInput(transactionId: transaction.id, wallet: model.wallet)
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
        refreshAcitities()
    }

    private func onDataRefresh() {
        refreshAcitities()
    }
}

// MARK: - Effects

extension TransactionsScene {
    private func refreshAcitities() {
        Task {
            await model.fetch()
        }
    }
}

// MARK: - Previews

#Preview {
    TransactionsScene(model: .init(wallet: .main, type: .all, service: .main))
}
