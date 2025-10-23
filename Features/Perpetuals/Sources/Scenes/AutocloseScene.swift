// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Localization
import Style
import PrimitivesComponents

public struct AutocloseScene: View {
    enum Field: Int, Hashable {
        case targetPrice
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
            Section {
                if model.hasTakeProfit {
                    ListItemView(
                        title: model.targetPriceTitle,
                        subtitle: model.currentTakeProfitPrice
                    )
                } else {
                    InputValidationField(
                        model: $model.inputModel,
                        placeholder: model.targetPriceTitle,
                        allowClean: true
                    )
                    .keyboardType(.decimalPad)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .focused($focusedField, equals: .targetPrice)
                }
            } header: {
                HStack {
                    Text(model.takeProfitTitle)
                    Spacer()
                    if model.hasTakeProfit {
                        Button(action: model.onSelectCancel) {
                            Text(Localized.Common.cancel)
                                .foregroundStyle(Colors.blue)
                        }
                    }
                }
                .font(.subheadline)
                .fontWeight(.semibold)
            } footer: {
                HStack {
                    Text(model.expectedProfitTitle)
                    Spacer()
                    Text(model.expectedProfitText)
                        .foregroundStyle(model.expectedProfitColor)
                }
                .font(.subheadline)
                .fontWeight(.semibold)
            }
        }
        .contentMargins(.top, .scene.top, for: .scrollContent)
        .safeAreaView {
            VStack(spacing: 0) {
                Divider()
                    .frame(height: 1 / UIScreen.main.scale)
                    .background(Colors.grayVeryLight)
                    .isVisible(focusedField == .targetPrice)

                Group {
                    if model.showButton {
                        StateButton(
                            text: Localized.Transfer.confirm,
                            type: model.buttonType,
                            action: model.onSelectConfirm
                        )
                        .frame(maxWidth: .scene.button.maxWidth)
                    } else if focusedField == .targetPrice {
                        PercentageAccessoryView(
                            onSelectPercent: model.onSelectPercent,
                            onDone: model.onDone
                        )
                    }
                }
                .padding(.small)
            }
            .background(Colors.grayBackground)
        }
        .navigationTitle(model.title)
        .onChange(of: model.focusField, onChangeFocus)
    }
}

// MARK: - Actions

extension AutocloseScene {
    private func onChangeFocus(_ _: Field?, _ newField: Field?) {
        focusedField = newField
    }
}
