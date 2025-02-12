// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style
import Components
import Primitives
import PrimitivesComponents

public struct TransactionsFilterScene: View {
    @Environment(\.dismiss) private var dismiss
    @Binding private var model: TransactionsFilterViewModel

    @State private var isPresentingChains: Bool = false
    @State private var isPresentingTypes: Bool = false

    public init(model: Binding<TransactionsFilterViewModel>) {
        _model = model
    }

    public var body: some View {
        List {
            SelectFilterView(
                typeModel: model.chainsFilter.typeModel,
                action: onSelectChainsFilter
            )
            SelectFilterView(
                typeModel: model.transactionTypesFilter.typeModel,
                action: onSelectTypesFilter
            )
        }
        .listStyle(.insetGrouped)
        .navigationTitle(model.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if model.isAnyFilterSpecified {
                ToolbarItem(placement: .cancellationAction) {
                    Button(model.clear, action: onSelectClear)
                        .bold()
                        .buttonStyle(.plain)
                }
            }
            ToolbarItem(placement: .primaryAction) {
                Button(model.done, action: onSelectDone)
                    .bold()
                    .buttonStyle(.plain)
            }
        }
        .sheet(isPresented: $isPresentingChains) {
            SelectableSheet(
                model: model.networksModel,
                onFinishSelection: onFinishSelection(chains:),
                listContent: { ChainView(model: ChainViewModel(chain: $0)) }
            )
        }
        .sheet(isPresented: $isPresentingTypes) {
            SelectableSheet(
                model: model.typesModel,
                onFinishSelection: onFinishSelection(types:),
                listContent: { 
                    ListItemView(title: TransactionTypeViewModel(type: $0).title)
                }
            )
        }
    }
}

// MARK: - Actions

extension TransactionsFilterScene {
    private func onSelectClear() {
        model.chainsFilter.selectedChains = []
        model.transactionTypesFilter.selectedTypes = []
    }

    private func onSelectDone() {
        dismiss()
    }

    private func onFinishSelection(chains: [Chain]) {
        model.chainsFilter.selectedChains = chains
    }

    private func onFinishSelection(types: [TransactionType]) {
        model.transactionTypesFilter.selectedTypes = types
    }

    private func onSelectChainsFilter() {
        isPresentingChains.toggle()
    }

    private func onSelectTypesFilter() {
        isPresentingTypes.toggle()
    }
}

#Preview {
    NavigationStack {
        TransactionsFilterScene(
            model:.constant(
                TransactionsFilterViewModel(
                    chainsFilterModel: ChainsFilterViewModel(
                        chains: [.aptos, .arbitrum]
                    ),
                    transactionTypesFilter: TransacionTypesFilterViewModel(
                        types: [.swap, .stakeDelegate]
                    )
                )
            )
        )
    }
}
