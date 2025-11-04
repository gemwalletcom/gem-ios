// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Localization
import Style
import PrimitivesComponents

public struct AutocloseScene: View {
    enum Field: Int, Hashable {
        case takeProfit
        case stopLoss
    }
    @FocusState private var focusedField: Field?
    @State private var model: AutocloseSceneViewModel

    public init(model: AutocloseSceneViewModel) {
        _model = State(initialValue: model)
    }

    public var body: some View {
        List {
            Section {
                ListItemView(
                    title: model.entryPriceTitle,
                    subtitle: model.entryPriceText
                )
                ListItemView(
                    title: model.marketPriceTitle,
                    subtitle: model.marketPriceText
                )
            }

            AutocloseInputSection(
                inputModel: $model.takeProfitInput,
                title: model.takeProfitTitle,
                placeholder: model.priceTitle,
                pnlTitle: model.pnlTitle,
                pnlText: model.expectedProfitText,
                pnlColor: model.expectedProfitColor,
                field: Field.takeProfit,
                focusedField: $focusedField
            )

            AutocloseInputSection(
                inputModel: $model.stopLossInput,
                title: model.stopLossTitle,
                placeholder: model.priceTitle,
                pnlTitle: model.pnlTitle,
                pnlText: model.expectedStopLossText,
                pnlColor: model.expectedStopLossColor,
                field: Field.stopLoss,
                focusedField: $focusedField
            )

            Section {
                StateButton(
                    text: Localized.Transfer.confirm,
                    type: .primary(),
                    action: model.onSelectConfirm
                )
                .frame(maxWidth: .infinity)
                .listRowInsets(EdgeInsets())
            }
        }
        .contentMargins(.top, .scene.top, for: .scrollContent)
        .safeAreaView {
            VStack(spacing: 0) {
                Divider()
                    .frame(height: 1 / UIScreen.main.scale)
                    .background(Colors.grayVeryLight)
                    .isVisible(focusedField != nil)

                if focusedField != nil {
                    PercentageAccessoryView(
                        onSelectPercent: model.onSelectPercent,
                        onDone: model.onDone
                    )
                    .padding(.small)
                }
            }
            .background(Colors.grayBackground)
        }
        .navigationTitle(model.title)
        .onChange(of: focusedField, model.onChangeFocusField)
        .onChange(of: model.focusField, onChangeFocus)
    }
}

// MARK: - Actions

extension AutocloseScene {
    private func onChangeFocus(_ _: Field?, _ newField: Field?) {
        focusedField = newField
    }
}
