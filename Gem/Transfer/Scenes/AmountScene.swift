// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Blockchain
import Style
import Components
import Primitives
import GemstonePrimitives

struct AmountScene: View {

    @StateObject var model: AmounViewModel
    @Environment(\.keystore) private var keystore
    @Environment(\.nodeService) private var nodeService

    @State private var isPresentingErrorMessage: String?
    @State private var isPresentingScanner: AmountScene.Field?
    @State private var isPresentingContacts: Bool = false

    // focus
    enum Field: Int, Hashable, Identifiable {
        case amount
        case address
        case memo
        var id: String { String(rawValue) }
    }
    @FocusState private var focusedField: Field?

    // next scene
    @State var transferData: TransferData?
    @State var delegation: DelegationValidator?

    @State var amount: String = ""
    @State var address: String = ""
    @State var memo: String = ""

    @State var nameResolveState: NameRecordState = .none

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

                switch model.type {
                case .transfer:
                    Section(Localized.Transfer.Recipient.title) {
                        FloatTextField(model.recipientField, text: $address, allowClean: false) {
                            HStack(spacing: Spacing.large/2) {
                                NameRecordView(
                                    model: NameRecordViewModel(chain: model.asset.chain),
                                    state: $nameResolveState,
                                    address: $address
                                )
                                ListButton(image: Image(systemName: SystemImage.paste)) {
                                    paste(field: .address)
                                }
                                ListButton(image: Image(systemName: SystemImage.qrCode)) {
                                    isPresentingScanner = .address
                                }
//                                ListButton(image: Image(systemName: SystemImage.book)) {
//                                    isPresentingContacts = true
//                                }
                            }
                        }
                        .focused($focusedField, equals: .address)
                        .keyboardType(.alphabet)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()

                        if model.showMemo {
                            FloatTextField(model.memoField, text: $memo) {
                                ListButton(image: Image(systemName: SystemImage.qrCode)) {
                                    isPresentingScanner = .memo
                                }
                            }
                            .focused($focusedField, equals: .memo)
                            .keyboardType(.alphabet)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                        }
                    }
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
                }

                if model.isBalanceViewEnabled {
                    Section {
                        VStack {
                            ListItemFlexibleView(
                                left: {
                                    AssetImageView(assetImage: model.assetImage)
                                },
                                primary: {
                                    VStack(alignment: .leading, spacing: Spacing.tiny) {
                                        Text(model.assetName)
                                            .textStyle(
                                                TextStyle(font: .body, color: .primary, fontWeight: .semibold)
                                            )
                                        Text(model.balanceText)
                                            .textStyle(TextStyle(font: .callout, color: Colors.gray, fontWeight: .medium))
                                    }
                                },
                                secondary: {
                                    Button(Localized.Transfer.max, action: useMax)
                                        .buttonStyle(.lightGray(paddingHorizontal: Spacing.medium, paddingVertical: Spacing.small))
                                        .fixedSize()
                                }
                            )
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .listSectionSpacing(.compact)

            Spacer()
            Button(Localized.Common.continue, action: {
                next()
            })
            .padding(.bottom, Spacing.scene.bottom)
            .frame(maxWidth: Spacing.scene.button.maxWidth)
            .buttonStyle(.blue())
        }
        .navigationBarTitleDisplayMode(.inline)
        .background(Colors.grayBackground)
        .navigationTitle(model.title)
        .sheet(item: $isPresentingScanner) { value in
            ScanQRCodeNavigationStack() {
                onHandleScan($0, for: value)
            }
        }
        .sheet(isPresented: $isPresentingContacts) {
            ContactsNavigationStack(
                wallet: model.wallet,
                asset: model.asset
            )
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(Localized.Common.next) {
                    next()
                }.bold()
            }
        }
        .navigationDestination(for: $transferData) {
            ConfirmTransferScene(
                model: ConfirmTransferViewModel(
                    wallet: model.wallet,
                    keystore: keystore,
                    data: $0,
                    service: ChainServiceFactory(nodeProvider: nodeService)
                        .service(for: $0.recipientData.asset.chain),
                    walletsService: model.walletsService
                )
            )
            .navigationBarTitleDisplayMode(.inline)
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

    func next() {
        //TODO: Move validation per field on demand

        next(amount: amount, name: nameResolveState.result, address: address, memo: memo, canChangeValue: true)
    }

    func next(amount: String, name: NameRecord?, address: String, memo: String?, canChangeValue: Bool) {
        do {
            let value = try model.isValidAmount(amount: amount)
            let recipientData = try model.getRecipientData(name: nameResolveState.result, address: address, memo: memo)
            let transfer = try model.getTransferData(recipientData: recipientData, value: value, canChangeValue: canChangeValue)

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

// MARK: - Actions

extension AmountScene {
    private func paste(field: Self.Field) {
        guard let string = UIPasteboard.general.string else { return }
        switch field {
        case .address, .memo, .amount:
            self.address = string.trim()
        }
    }

    private func onHandleScan(_ result: String, for field: Self.Field) {
        switch field {
        case .address:
            do {
                let result = try model.getTransferDataFromScan(string: result)

                // special case when all data is ready
                if let amount = result.amount, (model.showMemo ? !memo.isEmpty : true) {
                    next(amount: amount, name: .none, address: result.address, memo: memo, canChangeValue: false)
                } else {

                    address = result.address
                    memo = result.memo ?? ""
                    amount = result.amount ?? ""

//                    if !address.isEmpty && (model.showMemo ? !memo.isEmpty : true) && !amount.isEmpty {
//                        self.focusedField = .none
//                    }
                }
            } catch {
                isPresentingErrorMessage = error.localizedDescription
            }
        case .memo, .amount:
            memo = result
        }
    }
}
