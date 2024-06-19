// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives

struct TransactionsList: View {
    
    let transactions: [Primitives.TransactionExtended]
    let showSections: Bool

    private let tabScrollToTopId: TabScrollToTopId?

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
        showSections: Bool = true,
        tabScrollToTopId: TabScrollToTopId? = nil
    ) {
        self.transactions = transactions
        self.showSections = showSections
        self.tabScrollToTopId = tabScrollToTopId
    }
    
    var body: some View {
        if showSections {
            ForEach(headers, id: \.self) { header in
                Section(
                    header: Text(TransactionDateFormatter(date: header).section)
                ) {
                    TransactionsListView(
                        transactions: groupedByDate[header]!,
                        tabScrollToTopId: tabScrollToTopId
                    )
                }
            }
        } else {
            TransactionsListView(
                transactions: transactions,
                tabScrollToTopId: tabScrollToTopId
            )
        }
    }
}

private struct TransactionsListView: View {
    let transactions: [Primitives.TransactionExtended]
    private let tabScrollToTopId: TabScrollToTopId?

    init(
        transactions: [Primitives.TransactionExtended],
        tabScrollToTopId: TabScrollToTopId?
    ) {
        self.transactions = transactions
        self.tabScrollToTopId = tabScrollToTopId
    }

    var body: some View {
        ForEach(0..<transactions.count, id: \.self) { index in
            let transaction = transactions[0]
            NavigationLink(value: transaction) {
                TransactionView(model: .init(transaction: transaction, formatter: .short))
            }
            .if(tabScrollToTopId != nil && index == 0) {
                $0.id(tabScrollToTopId)
            }
        }
    }
}

struct ActivityList_Previews: PreviewProvider {
    static var previews: some View {
        TransactionsList([])
    }
}
