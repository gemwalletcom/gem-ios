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
                    HStack {
                        EmojiView(
                            color: Colors.grayBackground,
                            emoji: feeRate.emoji
                        )
                        .frame(width: Sizing.image.asset, height: Sizing.image.asset)

                        ListItemSelectionView(
                            title: feeRate.title,
                            titleExtra: feeRate.valueText,
                            titleTag: .none,
                            titleTagType: .none,
                            subtitle: .none,
                            subtitleExtra: .none,
                            value: feeRate.feeRate.priority,
                            selection: model.priority,
                            action: {
                                model.priority = $0
                                dismiss()
                            }
                        )
                    }
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
        
        .contentMargins(.top, .scene.top, for: .scrollContent)
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
