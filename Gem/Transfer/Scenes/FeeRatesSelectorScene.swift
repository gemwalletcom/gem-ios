// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Primitives

struct FeeRatesSelectorScene: View {
    @Environment(\.dismiss) private var dismiss

    private var model: FeeRatesSelectorViewModel

    var action: ((FeePriority) -> Void)

    init(model: FeeRatesSelectorViewModel, action: @escaping ((FeePriority) -> Void)) {
        self.model = model
        self.action = action
    }

    var body: some View {
        List {
            Section {
                ForEach(model.feeRatesViewModels) { feeRate in
                    SelectionListItemView(
                        title: feeRate.title,
                        titleExtra: .none,
                        subtitle: feeRate.value,
                        subtitleExtra: .none,
                        selectionDirection: .left,
                        value: feeRate.feeRate.priority,
                        selection: model.selectedFeeRate?.priority,
                        action: action)
                }
            } footer: {
                Text(Localized.FeeRates.info)
                    .textStyle(.caption)
                    .multilineTextAlignment(.leading)
                    .headerProminence(.increased)
            }
            ListItemView(
                title: model.networkFeeTitle,
                subtitle: model.networkFeeValue,
                subtitleExtra: model.networkFeeFiatValue,
                placeholders: [.subtitle]
            )
        }
        .navigationTitle(Localized.Transfer.networkFee)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button {
                    dismiss()
                } label: {
                    Text(Localized.Common.cancel)
                }
            }
        }
    }
}

// MARK: - Previews

#Preview {
    FeeRatesSelectorScene(
        model: .init(
            feeRates: [.init(priority: .fast,
                             rate: 4004.asBigInt)],
            chain: .bitcoin,
            networkFeeValue: "-",
            networkFeeFiatValue: "-"
        )
    ) { _ in }
}
