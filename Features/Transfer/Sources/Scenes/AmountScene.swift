// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style
import Components
import Primitives
import PrimitivesComponents
import struct Staking.StakeValidatorViewModel
import struct Staking.ValidatorView

struct AmountScene: View {
    @FocusState private var focusedField: Bool

    private var model: AmountSceneViewModel

    public init(model: AmountSceneViewModel) {
        self.model = model
    }

    var body: some View {
        ListSectionView(
            provider: model,
            content: content(for:)
        )
        .safeAreaView {
            StateButton(
                text: model.continueTitle,
                type: .primary(model.actionButtonState),
                action: model.onSelectNextButton
            )
            .frame(maxWidth: .scene.button.maxWidth)
            .padding(.bottom, .scene.bottom)
        }
        .contentMargins([.top], .zero, for: .scrollContent)
        .listSectionSpacing(.custom(.medium))
        .frame(maxWidth: .infinity)
        .navigationTitle(model.title)
        .onAppear(perform: model.onAppear)
        .onChange(of: model.focusField, onChangeFocus)
    }
}

// MARK: - UI Components

extension AmountScene {
    @ViewBuilder
    private func content(for itemModel: AmountItemModel) -> some View {
        @Bindable var bindableModel = model
        switch itemModel {
        case .input:
            CurrencyInputValidationView(
                model: $bindableModel.amountInputModel,
                config: model.inputConfig,
                infoAction: model.infoAction(for:)
            )
            .padding(.top, .medium)
            .listGroupRowStyle()
            .disabled(model.isInputDisabled)
            .focused($focusedField)
        case .balance(let balanceModel):
            AssetBalanceView(
                image: balanceModel.assetImage,
                title: balanceModel.assetName,
                balance: balanceModel.balanceText,
                secondary: {
                    Button(
                        balanceModel.maxTitle,
                        action: model.onSelectMaxButton
                    )
                    .buttonStyle(.listEmpty(paddingHorizontal: .medium, paddingVertical: .small))
                    .fixedSize()
                }
            )
        case .info(let infoModel):
            Button(action: model.onSelectReservedFeesInfo) {
                HStack {
                    Images.System.info
                        .foregroundStyle(Colors.gray)
                        .frame(width: .list.image, height: .list.image)
                    Text(infoModel.text)
                        .textStyle(.calloutSecondary)
                }
            }
        case .validator(let validatorModel):
            if validatorModel.isSelectable {
                NavigationCustomLink(
                    with: ValidatorView(model: validatorModel.validator),
                    action: model.onSelectCurrentValidator
                )
            } else {
                ValidatorView(model: validatorModel.validator)
            }
        case .resource(let resourceModel):
            Picker("", selection: $bindableModel.selectedResource) {
                ForEach(resourceModel.resources) { resource in
                    Text(resource.title).tag(resource)
                }
            }
            .pickerStyle(.segmented)
            .frame(width: 200)
        case .leverage(let leverageModel):
            NavigationCustomLink(
                with: ListItemView(model: leverageModel),
                action: model.onSelectLeverage
            )
        case .autoclose(let autocloseModel):
            NavigationCustomLink(
                with: ListItemView(model: autocloseModel),
                action: model.onSelectAutoclose
            )
        case .empty:
            EmptyView()
        }
    }
}

// MARK: - Actions

extension AmountScene {
    private func onChangeFocus(_ _: Bool, _ newField: Bool) {
        focusedField = newField
    }
}
