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
                ListAssetItemView(
                    model: PerpetualPositionItemViewModel(model: model.positionViewModel)
                )
            }

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
                inputModel: $model.input.takeProfit,
                sectionModel: model.takeProfitModel,
                field: Field.takeProfit,
                focusedField: $focusedField
            )

            AutocloseInputSection(
                inputModel: $model.input.stopLoss,
                sectionModel: model.stopLossModel,
                field: Field.stopLoss,
                focusedField: $focusedField
            )

            Section {
                StateButton(
                    text: Localized.Transfer.confirm,
                    type: model.confirmButtonType,
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
        .onChange(of: model.input.focusField, onChangeFocus)
    }
}

// MARK: - Actions

extension AutocloseScene {
    private func onChangeFocus(_ _: Field?, _ newField: Field?) {
        focusedField = newField
    }
}
