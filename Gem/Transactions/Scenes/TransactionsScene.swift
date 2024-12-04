// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Primitives
import GRDBQuery
import Store
import Style
import Localization

struct TransactionsScene: View {
    private var model: TransactionsViewModel

    @Query<TransactionsRequest>
    private var transactions: [TransactionExtended]

    init(model: TransactionsViewModel) {
        self.model = model
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
        .onChange(of: model.filterModel.transactionTypesFilter.selectedTypes, onChangeTypes)
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
        model.update(filterRequest: .chains(chains.map({ $0.rawValue })))
    }

    private func onChangeTypes(_ _: [TransactionType], _ types: [TransactionType]) {
        model.update(filterRequest: .types(types.map({ $0.rawValue })))
    }

    private func fetch() async {
        await model.fetch()
    }
}

// MARK: - Previews

#Preview {
    TransactionsScene(model: .init(wallet: .main, type: .all, service: .main))
}
