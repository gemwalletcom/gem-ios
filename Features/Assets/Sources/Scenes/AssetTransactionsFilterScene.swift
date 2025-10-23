// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style
import Components
import Primitives
import PrimitivesComponents
import Localization
import Transactions

public struct AssetTransactionsFilterScene: View {
    @Environment(\.dismiss) private var dismiss
    @Binding private var model: TransactionsFilterViewModel

    public init(model: Binding<TransactionsFilterViewModel>) {
        _model = model
    }

    public var body: some View {
        SelectableSheet(
            model: model.typesModel,
            onFinishSelection: onFinishSelection(value:),
            listContent: {
                ListItemView(title: TransactionFilterTypeViewModel(type: $0).title)
            }
        )
        .presentationDetentsForCurrentDeviceSize(expandable: true)
        .presentationDragIndicator(.visible)
    }
}

// MARK: - Actions

extension AssetTransactionsFilterScene {
    private func onFinishSelection(value: SelectionResult<TransactionFilterType>) {
        model.transactionTypesFilter.selectedTypes = value.items
        if value.isConfirmed {
            dismiss()
        }
    }
}
