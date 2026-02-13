// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Primitives
import Store
import Style
import Localization
import PrimitivesComponents

public struct TransactionsScene: View {
    private var model: TransactionsViewModel

    public init(model: TransactionsViewModel) {
        self.model = model
    }

    public var body: some View {
        VStack {
            List {
                TransactionsList(
                    explorerService: model.explorerService,
                    model.transactions,
                    currency: model.currency
                )
                .listRowInsets(.assetListRowInsets)
            }
            .listSectionSpacing(.compact)
            .scrollContentBackground(.hidden)
            .refreshableTimer(every: .minutes(5)) {
                await model.fetch()
            }
        }
        .background { Colors.insetGroupedListStyle.ignoresSafeArea() }
        .overlay {
            if model.transactions.isEmpty {
                EmptyContentView(model: model.emptyContentModel)
                    .padding(.horizontal, .medium)
            }
        }
        .task { await model.fetch() }
    }
}
