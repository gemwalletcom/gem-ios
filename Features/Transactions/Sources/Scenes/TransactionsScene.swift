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

    @Query<TransactionsRequest>
    private var transactions: [TransactionExtended]

    public init(model: TransactionsViewModel) {
        self.model = model
        let request = Binding {
            model.request
        } set: { new in
            model.request = new
        }
        _transactions = Query(request)
    }

    public var body: some View {
        List {
            TransactionsList(
                explorerService: model.explorerService,
                transactions
            )
        }
        .onChange(of: model.filterModel, model.onChangeFilter)
        .listSectionSpacing(.compact)
        .refreshable(action: model.fetch)
        .background(Colors.grayBackground)
        .overlay {
            if transactions.isEmpty {
                EmptyContentView(model: model.emptyContentModel)
            }
        }
        .task {
            await model.fetch()
        }
    }
}
