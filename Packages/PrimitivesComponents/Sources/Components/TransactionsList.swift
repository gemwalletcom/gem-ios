// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import Components
import Style

public struct TransactionsList: View {

    let transactions: [Primitives.TransactionExtended]
    let showSections: Bool
    let explorerService: any ExplorerLinkFetchable
    let currency: String
    let filterButtonAction: (() -> Void)?
    let isFilterActive: Bool

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
        showSections: Bool = true,
        filterButtonAction: (() -> Void)? = nil,
        isFilterActive: Bool = false
    ) {
        self.explorerService = explorerService
        self.transactions = transactions
        self.currency =  currency
        self.showSections = showSections
        self.filterButtonAction = filterButtonAction
        self.isFilterActive = isFilterActive
    }

    public var body: some View {
        if showSections {
            ForEach(headers.enumerated().map { $0 }, id: \.element) { index, header in
                Section(
                    header: sectionHeader(for: header, isFirst: index == 0)
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

    @ViewBuilder
    private func sectionHeader(for date: Date, isFirst: Bool) -> some View {
        if isFirst, let action = filterButtonAction {
            HStack {
                Text(TransactionDateFormatter(date: date).section)
                Spacer()
                FilterButton(isActive: isFilterActive, action: action)
                    .foregroundStyle(Colors.gray)
            }
        } else {
            Text(TransactionDateFormatter(date: date).section)
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
