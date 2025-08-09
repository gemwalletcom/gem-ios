// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives

public struct TransactionsList: View {

    let transactions: [Primitives.TransactionExtended]
    let showSections: Bool
    let explorerService: any ExplorerLinkFetchable
    let currency: String

    var groupedByDate: [Date: [Primitives.TransactionExtended]] {
        Dictionary(grouping: transactions, by: {
            Calendar.current.startOfDay(for: $0.transaction.createdAt)
        })
    }

    var headers: [Date] {
        groupedByDate.map({ $0.key }).sorted(by: >)
    }

    public init(
        explorerService: any ExplorerLinkFetchable,
        _ transactions: [Primitives.TransactionExtended],
        currency: String,
        showSections: Bool = true
    ) {
        self.explorerService = explorerService
        self.transactions = transactions
        self.currency =  currency
        self.showSections = showSections
    }

    public var body: some View {
        if showSections {
            ForEach(headers, id: \.self) { header in
                Section(
                    header: Text(TransactionDateFormatter(date: header).section)
                ) {
                    TransactionsListView(
                        explorerService: explorerService,
                        transactions: groupedByDate[header]!,
                        currency: currency
                    )
                }
            }
        } else {
            TransactionsListView(
                explorerService: explorerService,
                transactions: transactions,
                currency: currency
            )
        }
    }
}

private struct TransactionsListView: View {
    let transactions: [Primitives.TransactionExtended]
    let explorerService: any ExplorerLinkFetchable
    let currency: String

    init(explorerService: any ExplorerLinkFetchable,
         transactions: [Primitives.TransactionExtended],
         currency: String
    ) {
        self.explorerService = explorerService
        self.transactions = transactions
        self.currency = currency
    }

    var body: some View {
        ForEach(transactions) { transaction in
            NavigationLink(value: transaction) {
                TransactionView(
                    model: .init(
                        explorerService: explorerService,
                        transaction: transaction,
                        currency: currency
                    )
                )
            }
        }
    }
}
