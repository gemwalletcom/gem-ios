// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Blockchain
import Style
import Components
import Primitives
import GemstonePrimitives
import Localization
import class Staking.StakeValidatorsViewModel
import struct Staking.StakeValidatorViewModel
import struct Staking.ValidatorView
import struct Staking.StakeValidatorsScene

struct AmountScene: View {

    @State var model: AmounViewModel
    @Environment(\.keystore) private var keystore
    @Environment(\.nodeService) private var nodeService

    @FocusState private var focusedField: Bool

    @State private var isPresentingErrorMessage: String?

    var body: some View {
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
                                Button(Localized.Transfer.max, action: setMax)
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
                    if let validator = model.currentValidator  {
                        Section(Localized.Stake.validator) {
                            //TODO: Use this, other option does not work for some reason
                            /*
                             NavigationLink(value: Scenes.Validators()) {
                             ListItemView(title: validator.name, subtitle: .none)
                             }
                             */
                            if model.isSelectValidatorEnabled {
                                NavigationCustomLink(with: ValidatorView(model: StakeValidatorViewModel(validator: validator))) {
                                    model.setCurrentValidator()
                                }
                            } else {
                                ValidatorView(model: StakeValidatorViewModel(validator: validator))
                            }
                        }
                    }
                }
                
                
            }
            .contentMargins([.top], .zero, for: .scrollContent)
            //.listSectionSpacing(.compact)

            Spacer()
            Button(Localized.Common.continue, action: next)
            .frame(maxWidth: .scene.button.maxWidth)
            .buttonStyle(.blue())
        }
        .padding(.bottom, .scene.bottom)
        .background(Colors.grayBackground)
        .frame(maxWidth: .infinity)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(model.title)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(Localized.Common.next) {
                    next()
                }.bold()
            }
        }
        .navigationDestination(for: $model.delegation) { value in
            StakeValidatorsScene(
                model: StakeValidatorsViewModel(
                    type: model.stakeValidatorsType,
                    chain: model.asset.chain,
                    currentValidator: value,
                    validators: model.validators,
                    selectValidator: onSelectValidator
                )
            )
        }
        .onAppear {
            if model.isAmountChangable {
                if focusedField == false {
                    focusedField = true
                }
                UITextField.appearance().clearButtonMode = .never
            } else {
                setMax()
            }
        }
        .taskOnce {
            model.setRecipientAmount()
        }
        .alert(item: $isPresentingErrorMessage) {
            Alert(title: Text(""), message: Text($0))
        }
    }
}

// MARK: - Actions

extension AmountScene {
    private func next() {
        do {
            try model.onNext()
        } catch {
            isPresentingErrorMessage = error.localizedDescription
        }
    }

    private func setMax() {
        model.setMax()
        focusedField = false
    }
    
    private func onSelectValidator(_ validator: DelegationValidator) {
        model.resetAmount()
        model.setSelectedValidator(validator)
    }
}
