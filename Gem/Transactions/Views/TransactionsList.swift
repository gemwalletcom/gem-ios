// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives

struct TransactionsList: View {
    
    let transactions: [Primitives.TransactionExtended]
    let showSections: Bool

    var groupedByDate: [Date: [Primitives.TransactionExtended]] {
        Dictionary(grouping: transactions, by: {
            Calendar.current.startOfDay(for: $0.transaction.createdAt)
        })
    }

    var headers: [Date] {
        groupedByDate.map({ $0.key }).sorted(by: >)
    }
    
    init(
        _ transactions: [Primitives.TransactionExtended],
        showSections: Bool = true
    ) {
        self.transactions = transactions
        self.showSections = showSections
    }
    
    var body: some View {
        if showSections {
            ForEach(headers, id: \.self) { header in
                Section(
                    header: Text(TransactionDateFormatter(date: header).section)
                ) {
                    TransactionsListView(transactions: groupedByDate[header]!)
                }
            }
        } else {
            TransactionsListView(transactions: transactions)
        }
    }
}

private struct TransactionsListView: View {
    let transactions: [Primitives.TransactionExtended]
    
    var body: some View {
        ForEach(transactions, id: \.self) { transaction in
            NavigationLink(value: transaction) {
                TransactionView(model: .init(transaction: transaction, formatter: .short))
            }
        }
    }
}

struct ActivityList_Previews: PreviewProvider {
    static var previews: some View {
        TransactionsList([])
    }
}
