// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Localization
import Style
import PrimitivesComponents

public struct AutocloseScene: View {
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
                    title: model.markPriceTitle,
                    subtitle: model.markPriceText
                )
            }

            Section {
                InputValidationField(
                    model: $model.takeProfitInputModel,
                    placeholder: model.targetPricePlaceholder,
                    allowClean: true
                )
                .keyboardType(.decimalPad)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
            } header: {
                Text(model.takeProfitTitle)
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
            StateButton(
                text: Localized.Transfer.confirm,
                type: model.buttonType,
                action: model.onSelectConfirmButton
            )
            .frame(maxWidth: .scene.button.maxWidth)
            .padding(.bottom, .scene.bottom)
        }
        .navigationTitle(model.title)
    }
}
