// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Primitives
import Localization
import Style

public struct NetworkFeeScene: View {
    @Environment(\.dismiss) private var dismiss

    private var model: NetworkFeeSceneViewModel

    public init(model: NetworkFeeSceneViewModel) {
        self.model = model
    }

    public var body: some View {
        List {
            Section {
                ForEach(model.feeRatesViewModels) { feeRate in
                    ListItemSelectionView(
                        title: feeRate.title,
                        titleExtra: feeRate.valueText,
                        titleTag: .none,
                        titleTagType: .none,
                        subtitle: .none,
                        subtitleExtra: .none,
                        image: feeRate.image,
                        imageSize: 28,
                        value: feeRate.feeRate.priority,
                        selection: model.priority,
                        action: {
                            model.priority = $0
                            dismiss()
                        }
                    )
                }
            } footer: {
                Text(model.infoIcon)
                    .textStyle(.caption)
                    .multilineTextAlignment(.leading)
                    .headerProminence(.increased)
            }
            ListItemView(
                title: model.title,
                subtitle: model.value,
                subtitleExtra: model.fiatValue,
                placeholders: [.subtitle]
            )
        }
        .navigationTitle(model.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button {
                    dismiss()
                } label: {
                    Text(model.doneTitle)
                        .bold()
                }
            }
        }
    }
}
