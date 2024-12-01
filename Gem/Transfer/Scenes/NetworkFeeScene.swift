// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Primitives
import Localization

struct NetworkFeeScene: View {
    @Environment(\.dismiss) private var dismiss

    private var model: NetworkFeeViewModel

    private var action: ((FeePriority) -> Void)

    init(model: NetworkFeeViewModel, action: @escaping ((FeePriority) -> Void)) {
        self.model = model
        self.action = action
    }

    var body: some View {
        List {
            Section {
                ForEach(model.feeRatesViewModels) { feeRate in
                    ListItemSelectionView(
                        title: feeRate.title,
                        titleExtra: feeRate.value,
                        titleTag: .none,
                        titleTagType: .none,
                        subtitle: .none,
                        subtitleExtra: .none,
                        image: feeRate.image,
                        imageSize: 28,
                        value: feeRate.feeRate.priority,
                        selection: model.selectedFeeRate?.priority,
                        action: action
                    )
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
                    Text(Localized.Common.done)
                }
            }
        }
    }
}

// MARK: - Previews

#Preview {
    NetworkFeeScene(
        model: .init(
            feeRates: [.init(priority: .fast,
                             gasPriceType: .regular(gasPrice: 4004))],
            chain: .bitcoin,
            networkFeeValue: "-",
            networkFeeFiatValue: "-"
        )
    ) { _ in }
}
