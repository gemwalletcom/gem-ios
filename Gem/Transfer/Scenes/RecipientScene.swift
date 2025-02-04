// Copyright (c). Gem Wallet. All rights reserved.

import Blockchain
import Components
import Localization
import NameResolver
import Primitives
import QRScanner
import Style
import SwiftUI
import Transfer

struct RecipientScene: View {
    @Environment(\.nodeService) private var nodeService

    @StateObject var model: RecipientViewModel

    @State private var address: String = ""
    @State private var memo: String = ""
    @State private var amount: String = ""
    @State private var nameResolveState: NameRecordState = .none
    @State private var isPresentingErrorMessage: String?
    @State private var isPresentingScanner: RecipientScene.Field?

    enum Field: Int, Hashable, Identifiable {
        case address
        case memo
        var id: String { String(rawValue) }
    }

    @FocusState private var focusedField: Field?

    var body: some View {
        VStack {
            List {
                Section {
                    FloatTextField(model.recipientField, text: $address, allowClean: false) {
                        HStack(spacing: Spacing.large / 2) {
                            NameRecordView(
                                model: NameRecordViewModel(chain: model.chain),
                                state: $nameResolveState,
                                address: $address
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

                    if model.showMemo {
                        FloatTextField(model.memoField, text: $memo, allowClean: focusedField == .memo) {
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
                                address = recipient.address
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
                                address = recipient.address
                                focusedField = .none
                            }
                        }
                    } header: {
                        Text("View Wallets")
                    }
                }
            }

            Spacer()
            Button(Localized.Common.continue, action: next)
                .frame(maxWidth: Spacing.scene.button.maxWidth)
                .buttonStyle(.blue())
        }
        .background(Colors.grayBackground)
        .navigationTitle(model.tittle)
        .sheet(item: $isPresentingScanner) { value in
            ScanQRCodeNavigationStack {
                onHandleScan($0, for: value)
            }
        }
        .alert(item: $isPresentingErrorMessage) {
            Alert(title: Text(""), message: Text($0))
        }
        .onChange(of: address) { _, _ in
            // sometimes amount scanned from QR, pass it over, only address is not changed
            if !amount.isEmpty {
                amount = .empty
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
            address = string.trim()
            // FIXME: remove this test code
            onHandleScan(string.trim(), for: .address)
        }
    }

    private func onHandleScan(_ result: String, for field: Self.Field) {
        switch field {
        case .address:
            do {
                let payment = try model.getPaymentType(string: result)
                let scanResult = try model.getRecipientScanResult(paymentType: payment)
                switch scanResult {
                case .transferData(let data):
                    model.onTransferDataSelect(data: data)
                case .recipient(let address, let memo, let amount):
                    self.address = address
                    if let memo = memo {
                        self.memo = memo
                    }
                    if let amount = amount {
                        self.amount = amount
                    }
                case .paymentLink(let link):
                    switch link {
                    case .solanaPay(let url):
                        Task {
                            let data = try await model.getSolanaPayLabel(link: url)
                            model.onPaymentLinkDataSelect(data: data)
                        }
                    }
                }
            } catch {
                isPresentingErrorMessage = error.localizedDescription
            }
        case .memo:
            memo = result
        }
    }

    func next() {
        do {
            let data = try model.getRecipientData(
                name: nameResolveState.result,
                address: address,
                memo: memo,
                amount: amount.isEmpty ? .none : amount
            )
            model.onRecipientDataSelect(data: data)
        } catch {
            isPresentingErrorMessage = error.localizedDescription
        }
    }
}

// struct TransferScene_Previews: PreviewProvider {
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
// }
