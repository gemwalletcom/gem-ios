// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Blockchain
import Style
import Components
import Primitives

struct AmountScene: View {

    @StateObject var model: AmounViewModel

    @Environment(\.nodeService) private var nodeService

    @State var amount: String = ""
    @State private var isPresentingErrorMessage: String?

    // focus
    private enum Field: Int, Hashable, Identifiable {
        case amount
        var id: String { String(rawValue) }
    }
    @FocusState private var focusedField: Field?

    // next scene
    @State var transferData: TransferData?
    @State var delegation: DelegationValidator?

    var body: some View {
        UITextField.appearance().clearButtonMode = .never

        return VStack {
            List {
                Section { } header: {
                    VStack(alignment: .center, spacing: 0) {
                        HStack(alignment: .center, spacing: 0) {
                            TextField(String.zero, text: $amount)
                                .keyboardType(.decimalPad)
                                .foregroundColor(Colors.black)
                                .font(.system(size: 52))
                                .fontWeight(.semibold)
                                .focused($focusedField, equals: .amount)
                                .multilineTextAlignment(.center)
                                .textFieldStyle(.plain)
                                .lineLimit(1)
                                //.minimumScaleFactor(0.5)
                                .frame(minWidth: 40, maxWidth: 260)
                                .padding(.trailing, 8)
                                .fixedSize(horizontal: true, vertical: false)
                                .disabled(model.isInputDisabled)

                            Text(model.assetSymbol)
                                .font(.system(size: 52))
                                .fontWeight(.semibold)
                                .lineLimit(1)
                                .foregroundColor(Colors.black)
                                .fixedSize()
                        }

                        ZStack {
                            Text(model.fiatAmount(amount: amount))
                                .font(Font.system(size: 16))
                                .fontWeight(.medium)
                                .foregroundColor(Colors.gray)
                                .frame(minHeight: 20)
                        }
                        .padding(.top, 0)
                    }
                    .padding(.top, 16)
                }
                .frame(maxWidth: .infinity)
                .textCase(nil)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets())

                if let validator = model.currentValidator  {
                    Section(Localized.Stake.validator) {
                        //TODO: Use this, other option does not work for some reason
                        /*
                        NavigationLink(value: Scenes.Validators()) {
                            ListItemView(title: validator.name, subtitle: .none)
                        }
                         */
                        if model.isSelectValidatorEnabled {
                            NavigationCustomLink(with:
                                HStack {
                                    ValidatorImageView(validator: validator)
                                    ListItemView(
                                        title: StakeValidatorViewModel(validator: validator).name,
                                        subtitle: StakeValidatorViewModel(validator: validator).aprText
                                    )
                                }
                            ) {
                                self.delegation = model.currentValidator
                            }
                        } else {
                            HStack {
                                ValidatorImageView(validator: validator)
                                ListItemView(
                                    title: StakeValidatorViewModel(validator: validator).name,
                                    subtitle: StakeValidatorViewModel(validator: validator).aprText
                                )
                            }
                        }
                    }
                }
                if model.isBalanceViewEnabled {
                    Section {
                        VStack {
                            AssetListItemView {
                                AssetImageView(assetImage: model.assetImage)
                            } primary: {
                                AnyView(
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(model.assetName)
                                            .font(.system(size: 16))
                                            .fontWeight(.semibold)
                                        Text(model.balanceText)
                                            .font(.system(size: 13))
                                            .fontWeight(.medium)
                                            .foregroundColor(Colors.gray)
                                    }
                                )
                            } secondary: {
                                AnyView(
                                    HStack {
                                        Button(Localized.Transfer.max, action: useMax)
                                            .buttonStyle(.lightGray(paddingHorizontal: Spacing.medium, paddingVertical: Spacing.small))
                                            .fixedSize()
                                    }
                                )
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }

            Spacer()

            Button(Localized.Common.continue, action: {
                Task { await next() }
            })
            .padding(.bottom, Spacing.scene.bottom)
            .frame(maxWidth: Spacing.scene.button.maxWidth)
            .buttonStyle(.blue())
        }
        .navigationBarTitleDisplayMode(.inline)
        .background(Colors.grayBackground)
        .navigationTitle(model.title)
        .navigationDestination(for: $transferData) {
            ConfirmTransferScene(
                model: ConfirmTransferViewModel(
                    wallet: model.wallet,
                    keystore: model.keystore,
                    data: $0,
                    service: ChainServiceFactory(nodeProvider: nodeService)
                        .service(for: model.amountRecipientData.data.asset.chain),
                    walletService: model.walletService
                )
            )
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
        .alert(item: $isPresentingErrorMessage) {
            Alert(title: Text(""), message: Text($0))
        }
    }

    func next() async {
        //TODO: Move validation per field on demand

        do {
            let value = try model.isValidAmount(amount: amount)
            let transfer = try model.getTransferData(value: value)
            transferData = transfer
        } catch {
            isPresentingErrorMessage = error.localizedDescription
        }
    }

    func useMax() {
        amount = model.maxBalance

        focusedField = .none
    }
}
