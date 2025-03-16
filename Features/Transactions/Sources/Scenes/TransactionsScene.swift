// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Primitives
import GRDBQuery
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
        List {
            TransactionsList(
                explorerService: model.explorerService,
                model.transactions
            )
        }
        .listSectionSpacing(.compact)
        .refreshable(action: model.fetch)
        .overlay {
            if model.transactions.isEmpty {
                EmptyContentView(model: model.emptyContentModel)
            }
        }
        .task {
            await model.fetch()
        }
    }
}
