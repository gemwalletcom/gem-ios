// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style
import Components
import Primitives
import PrimitivesComponents

public struct TransactionsFilterScene: View {
    @Environment(\.dismiss) private var dismiss
    @Binding private var model: TransactionsFilterViewModel

    public init(model: Binding<TransactionsFilterViewModel>) {
        _model = model
    }

    public var body: some View {
        List {
            SelectFilterView(
                typeModel: model.chainsFilter.typeModel,
                action: model.onSelectChainsFilter
            )
            SelectFilterView(
                typeModel: model.transactionTypesFilter.typeModel,
                action: model.onSelectTypesFilter
            )
        }
        .contentMargins(.top, .scene.top, for: .scrollContent)
        .listStyle(.insetGrouped)
        .navigationTitle(model.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if model.isAnyFilterSpecified {
                ToolbarItem(placement: .cancellationAction) {
                    Button(model.clear, action: onSelectClear)
                        .bold()
                }
            }
            ToolbarItem(placement: .primaryAction) {
                Button(model.done, action: onSelectDone)
                    .bold()
            }
        }
        .sheet(isPresented: $model.isPresentingChains) {
            SelectableSheet(
                model: model.networksModel,
                onFinishSelection: onFinishSelection(value:),
                listContent: { ChainView(model: ChainViewModel(chain: $0)) }
            )
        }
        .sheet(isPresented: $model.isPresentingTypes) {
            SelectableSheet(
                model: model.typesModel,
                onFinishSelection: onFinishSelection(value:),
                listContent: {
                    ListItemView(title: TransactionFilterTypeViewModel(type: $0).title)
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

    private func onFinishSelection(value: SelectionResult<Chain>) {
        model.chainsFilter.selectedChains = value.items
        if value.isConfirmed {
            dismiss()
        }
    }

    private func onFinishSelection(value: SelectionResult<TransactionFilterType>) {
        model.transactionTypesFilter.selectedTypes = value.items
        if value.isConfirmed {
            dismiss()
        }
    }
}
