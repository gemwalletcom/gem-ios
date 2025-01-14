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

struct AmountScene: View {

    @StateObject var model: AmounViewModel
    @Environment(\.keystore) private var keystore
    @Environment(\.nodeService) private var nodeService

    enum Field: Int, Hashable, Identifiable {
        case amount
        var id: String { String(rawValue) }
    }
    @FocusState private var focusedField: Field?

    @State private var amount: String = ""
    @State private var delegation: DelegationValidator?
    @State private var isPresentingErrorMessage: String?

    var body: some View {
        VStack {
            List {
                CurrencyInputView(
                    text: $amount,
                    currencySymbol: model.assetSymbol,
                    currencyPosition: .trailing,
                    secondaryText: model.fiatAmount(amount: amount),
                    keyboardType: .decimalPad
                )
                .padding(.top, Spacing.medium)
                .listGroupRowStyle()
                .disabled(model.isInputDisabled)
                .focused($focusedField, equals: .amount)

                if model.isBalanceViewEnabled {
                    AssetBalanceView(
                        image: model.assetImage,
                        title: model.assetName,
                        balance: model.balanceText,
                        secondary: {
                            Button(Localized.Transfer.max, action: useMax)
                                .buttonStyle(.lightGray(paddingHorizontal: Spacing.medium, paddingVertical: Spacing.small))
                                .fixedSize()
                        }
                    )
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
                                    self.delegation = model.currentValidator
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
            .frame(maxWidth: Spacing.scene.button.maxWidth)
            .buttonStyle(.blue())
        }
        .padding(.bottom, Spacing.scene.bottom)
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
        .navigationDestination(for: $delegation) { value in
            StakeValidatorsScene(
                model: StakeValidatorsViewModel(
                    type: model.stakeValidatorsType,
                    chain: model.asset.chain,
                    currentValidator: value,
                    validators: model.validators,
                    selectValidator: { validator in
                        amount = ""
                        model.currentValidator = validator
                    }
                )
            )
        }
        .onAppear {
            if model.isAmountChangable {
                if focusedField == nil {
                    focusedField = .amount
                }
                UITextField.appearance().clearButtonMode = .never
            } else {
                amount = model.maxBalance
            }
        }
        .taskOnce {
            if let amount = model.recipientData.amount {
                self.amount = amount
            }
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
            let value = try model.isValidAmount(amount: amount)
            let transfer = try model.getTransferData(
                recipientData: model.recipientData,
                value: value,
                canChangeValue: true
            )

            model.onTransferAction?(transfer)
        } catch {
            isPresentingErrorMessage = error.localizedDescription
        }
    }

    private func useMax() {
        amount = model.maxBalance

        focusedField = .none
    }
}
