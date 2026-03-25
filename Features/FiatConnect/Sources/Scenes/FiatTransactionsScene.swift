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
            ForEach(model.sections) { section in
                Section {
                    ForEach(section.values) {
                        let viewModel = FiatTransactionViewModel(info: $0)
                        if let url = viewModel.detailsUrl {
                            SafariNavigationLink(url: url) {
                                ListItemView(model: viewModel.listItemModel)
                            }
                        } else {
                            NavigationCustomLink(
                                with: ListItemView(model: viewModel.listItemModel),
                                action: {}
                            )
                        }
                    }
                } header: {
                    section.title.map { Text($0) }
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
        .refreshable { await model.fetch() }
        .navigationTitle(model.title)
        .task { await model.fetch() }
    }
}
