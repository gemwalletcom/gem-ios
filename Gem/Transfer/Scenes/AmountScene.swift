// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style
import Components
import Primitives
import struct Staking.StakeValidatorViewModel
import struct Staking.ValidatorView

struct AmountScene: View {
    private var model: AmountSceneViewModel
    @FocusState private var focusedField: Bool

    public init(model: AmountSceneViewModel) {
        self.model = model
        self.focusedField = focusedField
    }

    var body: some View {
        @Bindable var model = model
        VStack {
            List {
                CurrencyInputView(
                    text: $model.amountText,
                    config: model.inputConfig
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

                switch model.type {
                case .transfer:
                    EmptyView()
                case .stake, .unstake, .redelegate, .withdraw:
                    if let viewModel = model.stakeValidatorViewModel  {
                        Section(model.validatorTitle) {
                            if model.isSelectValidatorEnabled {
                                NavigationCustomLink(with: ValidatorView(model: viewModel)) {
                                    model.setCurrentValidator()
                                }
                            } else {
                                ValidatorView(model: viewModel)
                            }
                        }
                    }
                }
            }
            .contentMargins([.top], .zero, for: .scrollContent)

            Spacer()
            Button(
                model.continueTitle,
                action: model.onSelectNextButton
            )
            .frame(maxWidth: .scene.button.maxWidth)
            .buttonStyle(.blue())
        }
        .padding(.bottom, .scene.bottom)
        .background(Colors.grayBackground)
        .frame(maxWidth: .infinity)
        .navigationTitle(model.title)
        .onAppear(perform: model.onAppear)
        .taskOnce(model.setRecipientAmountIfNeeded)
        .onChange(of: model.focusField, onChangeFocus)
    }
}

// MARK: - Actions

extension AmountScene {
    private func onChangeFocus(_ _: Bool, _ newField: Bool) {
        focusedField = newField
    }
}
