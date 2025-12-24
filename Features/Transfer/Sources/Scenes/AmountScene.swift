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
        @Bindable var model = model
        List {
            CurrencyInputValidationView(
                model: $model.amountInputModel,
                config: model.inputConfig,
                infoAction: model.infoAction(for:)
            )
            .padding(.top, .medium)
            .listGroupRowStyle()
            .disabled(model.isInputDisabled)
            .focused($focusedField)

            if model.isBalanceViewEnabled {
                Section {
                    AssetBalanceView(
                        image: model.assetImage,
                        title: model.assetName,
                        balance: model.balanceText,
                        secondary: {
                            Button(model.maxTitle, action: onSelectMaxButton)
                                .buttonStyle(.listEmpty(paddingHorizontal: .medium, paddingVertical: .small))
                                .fixedSize()
                        }
                    )
                }
            }

            if let infoText = model.infoText {
                Section {
                    Button(action: model.onSelectReservedFeesInfo) {
                        HStack {
                            Images.System.info
                                .foregroundStyle(Colors.gray)
                                .frame(width: .list.image, height: .list.image)
                            Text(infoText)
                                .textStyle(.calloutSecondary)
                        }
                    }
                }
            }

            switch model.amountTypeModel {
            case .none:
                EmptyView()
            case .staking(let stakingModel):
                if let validatorModel = stakingModel.selectedItemViewModel,
                   let selectedItem = stakingModel.selectedItem {
                    Section(stakingModel.selectionTitle) {
                        if stakingModel.isSelectionEnabled {
                            NavigationLink(value: selectedItem) {
                                ValidatorView(model: validatorModel)
                            }
                        } else {
                            ValidatorView(model: validatorModel)
                        }
                    }
                }
            case .freeze(let freezeModel):
                if freezeModel.isSelectionEnabled {
                    Section {
                        Picker("", selection: Binding(
                            get: { freezeModel.selectedItem ?? .bandwidth },
                            set: { model.onSelectResource($0) }
                        )) {
                            ForEach(freezeModel.pickerItems()) { resource in
                                Text(resource.title).tag(resource.resource)
                            }
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 200)
                    }
                    .cleanListRow()
                }
            case .perpetual(let perpetualModel):
                if perpetualModel.isSelectionEnabled {
                    Section {
                        NavigationCustomLink(
                            with: ListItemView(
                                title: perpetualModel.selectionTitle,
                                subtitle: perpetualModel.leverageText,
                                subtitleStyle: perpetualModel.leverageTextStyle
                            ),
                            action: model.onSelectLeverage
                        )
                    }
                }
                if perpetualModel.isAutocloseEnabled {
                    Section {
                        NavigationCustomLink(
                            with: ListItemView(
                                title: perpetualModel.autocloseTitle,
                                subtitle: perpetualModel.autocloseText.subtitle,
                                subtitleExtra: perpetualModel.autocloseText.subtitleExtra
                            ),
                            action: model.onSelectAutoclose
                        )
                    }
                }
            }
        }
        .safeAreaView {
            StateButton(
                text: model.continueTitle,
                type: .primary(model.actionButtonState),
                action: onSelectNextButton
            )
            .frame(maxWidth: .scene.button.maxWidth)
            .padding(.bottom, .scene.bottom)
        }
        .contentMargins([.top], .zero, for: .scrollContent)
        .listSectionSpacing(.custom(.medium))
        .frame(maxWidth: .infinity)
        .navigationTitle(model.title)
        .onAppear {
            model.onAppear()
            if model.shouldFocusOnAppear {
                focusedField = true
            }
        }
    }
}

// MARK: - Actions

extension AmountScene {
    private func onSelectMaxButton() {
        focusedField = false
        model.onSelectMaxButton()
    }

    private func onSelectNextButton() {
        focusedField = false
        model.onSelectNextButton()
    }
}
