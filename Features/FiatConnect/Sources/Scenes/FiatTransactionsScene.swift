// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Primitives
import Store
import Style
import PrimitivesComponents

public struct FiatTransactionsScene: View {
    @State private var model: FiatTransactionsViewModel

    public init(model: FiatTransactionsViewModel) {
        _model = State(initialValue: model)
    }

    public var body: some View {
        List {
            Section { } header: {
                AssetPreviewView(model: model.assetModel)
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, .small)
            }
            .cleanListRow()
            ForEach(model.transactions) { transaction in
                NavigationLink(value: Scenes.FiatTransaction(walletId: model.walletId, asset: model.asset, transaction: transaction)) {
                    ListItemView(model: FiatTransactionViewModel(transaction: transaction).listItemModel)
                }
            }
            .listRowInsets(.assetListRowInsets)
        }
        .overlay {
            if model.transactions.isEmpty {
                EmptyContentView(model: model.emptyContentModel)
                    .padding(.horizontal, .medium)
            }
        }
        .contentMargins(.top, .scene.top, for: .scrollContent)
        .listSectionSpacing(.compact)
        .bindQuery(model.query)
        .navigationTitle(model.title)
        .task { await model.fetch() }
    }
}
