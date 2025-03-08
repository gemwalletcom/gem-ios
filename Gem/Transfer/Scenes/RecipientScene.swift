// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style
import Components
import QRScanner
import Blockchain
import Primitives
import Localization
import Transfer
import NameResolver
import GRDBQuery
import Store
import Contacts

struct RecipientScene: View {
    
    @State var model: RecipientViewModel
    
    @Query<ContactAddressInfoListRequest>
    private var addresses: [ContactAddressInfo]
    
    @State private var nameResolveState: NameRecordState = .none
    @State private var isPresentingErrorMessage: String?
    @State private var isPresentingScanner: RecipientScene.Field?
    
    enum Field: Int, Hashable, Identifiable {
        case address
        case memo
        var id: String { String(rawValue) }
    }
    
    @FocusState private var focusedField: Field?
    
    init(model: RecipientViewModel) {
        _model = State(initialValue: model)
        
        let request = Binding {
            model.addressListRequest
        } set: { new in
            model.addressListRequest = new
        }
        
        _addresses = Query(request)
    }
    
    var body: some View {
        VStack {
            List {
                Section {
                    FloatTextField(model.recipientField, text: $model.address, allowClean: false) {
                        HStack(spacing: .large/2) {
                            NameRecordView(
                                model: NameRecordViewModel(chain: model.chain),
                                state: $nameResolveState,
                                address: $model.address
                            )
                            ListButton(image: Images.System.paste) {
                                paste(field: .address)
                            }
                            ListButton(image: Images.System.qrCode) {
                                isPresentingScanner = .address
                            }
                        }
                    }
                    .focused($focusedField, equals: .address)
                    .keyboardType(.alphabet)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .truncationMode(.middle)

                    if model.showMemo {
                        FloatTextField(model.memoField, text: $model.memo, allowClean: focusedField == .memo) {
                            ListButton(image: Images.System.qrCode) {
                                isPresentingScanner = .memo
                            }
                        }
                        .focused($focusedField, equals: .memo)
                        .keyboardType(.alphabet)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    }
                }
                
                if !model.getRecipient(by: .wallets).isEmpty {
                    Section {
                        ForEach(model.getRecipient(by: .wallets)) { recipient in
                            NavigationCustomLink(with: ListItemView(title: recipient.name)) {
                                model.address = recipient.address
                                focusedField = .none
                            }
                        }
                    } header: {
                        Text("My Wallets")
                    }
                    
                }
                if !model.getRecipient(by: .view).isEmpty {
                    Section {
                        ForEach(model.getRecipient(by: .view)) { recipient in
                            NavigationCustomLink(with: ListItemView(title: recipient.name)) {
                                model.address = recipient.address
                                focusedField = .none
                            }
                        }
                    } header: {
                        Text("View Wallets")
                    }
                }
                if !model.buildListItemViews(addresses: addresses).isEmpty {
                    Section {
                        ForEach(model.buildListItemViews(addresses: addresses)) { item in
                                ContactAddressListItemView(
                                    name: item.name,
                                    address: item.address,
                                    memo: item.memo
                                ).onTapGesture {
                                    didSelect(item.object.address)
                                }
                        }
                    } header: {
                        Text("Contacts")
                    }
                }
            }
            Spacer()
            Button(Localized.Common.continue, action: next)
            .frame(maxWidth: .scene.button.maxWidth)
            .buttonStyle(.blue())

        }
        .background(Colors.grayBackground)
        .navigationTitle(model.tittle)
        .sheet(item: $isPresentingScanner) { value in
            ScanQRCodeNavigationStack() {
                onHandleScan($0, for: value)
            }
        }
        .alert(item: $isPresentingErrorMessage) {
            Alert(title: Text(""), message: Text($0))
        }
        .onChange(of: model.address) { oldValue, newValue in
            // sometimes amount scanned from QR, pass it over, only address is not changed
            if !model.amount.isEmpty {
                model.amount = .empty
            }
        }
    }
}

// MARK: - Actions

extension RecipientScene {
    private func paste(field: Self.Field) {
        guard let string = UIPasteboard.general.string else { return }
        switch field {
        case .address, .memo:
            self.model.address = string.trim()
        }
    }
    
    private func onHandleScan(_ result: String, for field: Self.Field) {
        switch field {
        case .address:
            do {
                let payment = try model.getPaymentScanResult(string: result)
                let scanResult = try model.getRecipientScanResult(payment: payment)
                switch scanResult {
                case .transferData(let data):
                    model.onTransferDataSelect(data: data)
                case .recipient(let address, let memo, let amount):
                    self.model.address = address
                    
                    if let memo = memo {
                        self.model.memo = memo
                    }
                    if let amount = amount {
                        self.model.amount = amount
                    }
                }
            } catch {
                isPresentingErrorMessage = error.localizedDescription
            }
        case .memo:
            model.memo = result
        }
    }
    
    func didSelect(_ address: ContactAddress) {
        model.onContactAddressSelected(address)
    }
    
    func next() {
        do {
            let data = try model.getRecipientData(
                name: nameResolveState.result,
                address: model.address,
                memo: model.memo,
                amount: model.amount.isEmpty ? .none : model.amount
            )
            model.onRecipientDataSelect(data: data)
        } catch {
            isPresentingErrorMessage = error.localizedDescription
        }
    }
}

//struct TransferScene_Previews: PreviewProvider {
//    static var previews: some View {
//        RecipientScene(
//            model: RecipientViewModel(
//                wallet: .main,
//                keystore: .main,
//                walletsService: .main,
//                assetModel: AssetViewModel(asset: .main)
//            )
//        )
//    }
//}
