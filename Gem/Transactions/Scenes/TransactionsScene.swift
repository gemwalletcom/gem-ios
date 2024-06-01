// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Primitives
import GRDBQuery
import Store

struct TransactionsScene: View {
    
    @Query<TransactionsRequest>
    var transactions: [TransactionExtended]
    
    @Environment(\.db) private var DB

    let model: TransactionsViewModel
    
    init(
        model: TransactionsViewModel
    ) {
        self.model = model
        _transactions = Query(constant: model.request, in: \.db.dbQueue)
    }
    
    var body: some View {
        VStack {
            if transactions.isEmpty {
                StateEmptyView(message: Localized.Activity.EmptyState.message)
            } else {
                List {
                    TransactionsList(transactions)
                }
            }
        }
        .refreshable {
            NSLog("TransactionsScene refreshable")
            Task {
                await model.fetch()
            }
        }
        .navigationTitle(model.title)
        .navigationDestination(for: TransactionExtended.self) { transaction in
            TransactionScene(
                input: TransactionSceneInput(transactionId: transaction.id, wallet: model.wallet)
            )
        }
        .onAppear {
            Task {
                await model.fetch()
            }
        }
    }
}

struct TransactionsScene_Previews: PreviewProvider {
    static var previews: some View {
        TransactionsScene(model: .init(wallet: .main, type: .all, service: .main))
    }
}
