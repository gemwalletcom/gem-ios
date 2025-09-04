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
        self.focusedField = focusedField
    }

    var body: some View {
        @Bindable var model = model
        VStack {
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
                                Button(
                                    model.maxTitle,
                                    action: model.onSelectMaxButton
                                )
                                .buttonStyle(.lightGray(paddingHorizontal: .medium, paddingVertical: .small))
                                .fixedSize()
                            }
                        )
                    }
                }
                
                if let infoText = model.infoText {
                    Section {
                        Text(infoText)
                            .textStyle(.calloutSecondary)
                    }
                }

                switch model.type {
                case .transfer, .deposit, .withdraw:
                    EmptyView()
                case .stake, .stakeUnstake, .stakeRedelegate, .stakeWithdraw:
                    if let viewModel = model.stakeValidatorViewModel  {
                        Section(model.validatorTitle) {
                            if model.isSelectValidatorEnabled {
                                NavigationCustomLink(
                                    with: ValidatorView(model: viewModel),
                                    action: model.onSelectCurrentValidator
                                )
                            } else {
                                ValidatorView(model: viewModel)
                            }
                        }
                        .listRowInsets(.assetListRowInsets)
                    }
                case .perpetual:
                    // PositionView()
                    EmptyView()
                }
            }
            .contentMargins([.top], .zero, for: .scrollContent)

            Spacer()
            StateButton(
                text: model.continueTitle,
                type: .primary(model.actionButtonState),
                action: model.onSelectNextButton
            )
            .frame(maxWidth: .scene.button.maxWidth)
        }
        .padding(.bottom, .scene.bottom)
        .background(Colors.grayBackground)
        .frame(maxWidth: .infinity)
        .navigationTitle(model.title)
        .onAppear(perform: model.onAppear)
        .onChange(of: model.focusField, onChangeFocus)
    }
}

// MARK: - Actions

extension AmountScene {
    private func onChangeFocus(_ _: Bool, _ newField: Bool) {
        focusedField = newField
    }
}
