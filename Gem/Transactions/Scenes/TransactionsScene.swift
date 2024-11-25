// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Primitives
import GRDBQuery
import Store
import Style
import Localization

struct TransactionsScene: View {
    @State private var model: TransactionsViewModel

    @Query<TransactionsRequest>
    private var transactions: [TransactionExtended]

    init(model: TransactionsViewModel) {
        _model = State(wrappedValue: model)
        let request = Binding {
            model.request
        } set: { new in
            model.request = new
        }
        _transactions = Query(request)
    }

    var body: some View {
        List {
            TransactionsList(transactions)
        }
        .onChange(of: model.filterModel.chainsFilter.selectedChains, onChangeChains)
        .listSectionSpacing(.compact)
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
        .task {
            await fetch()
        }
    }
}

// MARK: - Effects

extension TransactionsScene {
    private func onChangeChains(_ _: [Chain], _ chains: [Chain]) {
        model.updateFilterRequest(chains: chains)
    }

    private func fetch() async {
        await model.fetch()
    }
}

// MARK: - Previews

#Preview {
    TransactionsScene(model: .init(walletId: .main, wallet: .main, type: .all, service: .main))
}
