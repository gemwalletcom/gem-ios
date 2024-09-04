// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style
import Components
import QRScanner
import Blockchain
import Primitives

struct RecipientScene: View {
    
    let model: RecipientViewModel
    
    @Environment(\.keystore) private var keystore
    @Environment(\.nodeService) private var nodeService
    @Environment(\.walletsService) private var walletsService
    @Environment(\.stakeService) private var stakeService

    @State var address: String = ""
    @State var memo: String = ""
    @State private var isPresentingErrorMessage: String?
    @State private var isPresentingScanner: Field?

    // focus
    private enum Field: Int, Hashable, Identifiable {
        case address, memo
        var id: String { String(rawValue) }
    }
    @FocusState private var focusedField: Field?
    
    // next scene
    @State var recipientData: AmountRecipientData?
    @State var transferData: TransferData?
    
    @State var nameResolveState: NameRecordState = .none
    
    var body: some View {
        VStack {
            List {
                Section {
                    FloatTextField(model.recipientField, text: $address, allowClean: false) {
                        HStack(spacing: Spacing.large/2) {
                            NameRecordView(
                                model: NameRecordViewModel(chain: model.asset.chain),
                                state: $nameResolveState,
                                address: $address
                            )
                            ListButton(image: Image(systemName: SystemImage.paste)) {
                                paste()
                            }
                            ListButton(image: Image(systemName: SystemImage.qrCode)) {
                                isPresentingScanner = .address
                            }
                        }
                    }
                    .focused($focusedField, equals: .address)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                }

                if model.showMemo {
                    FloatTextField(model.memoField, text: $memo) {
                        ListButton(image: Image(systemName: SystemImage.qrCode)) {
                            isPresentingScanner = .memo
                        }
                    }
                    .focused($focusedField, equals: .memo)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
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
            Button(Localized.Common.continue, action: {
                Task { next() }
            })
            .buttonStyle(.blue())
            .padding(.bottom, Spacing.scene.bottom)
            .frame(maxWidth: Spacing.scene.button.maxWidth)
        }
        .onAppear {
            focusedField = .address
        }
        .background(Colors.grayBackground)
        .sheet(item: $isPresentingScanner) { value in
            ScanQRCodeNavigationStack() {
                onHandleScan($0, for: value)
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
                    walletsService: walletsService
                )
            )
        }
        .navigationDestination(for: $recipientData) { data in
            AmountScene(
                model: AmounViewModel(
                    amountRecipientData: data,
                    wallet: model.wallet,
                    keystore: keystore,
                    walletsService: walletsService,
                    stakeService: stakeService
                )
            )
        }
        .alert(item: $isPresentingErrorMessage) {
            Alert(title: Text(Localized.Errors.transfer("")), message: Text($0))
        }
        .navigationTitle(model.tittle)
    }
    
    private func onHandleScan(_ result: String, for field: RecipientScene.Field) {
        switch field {
        case .address:
            do {
                let result = try model.getTransferDataFromScan(string: result)
                switch result {
                case .address(let address, let memo):
                    self.address = address
                    if let memo = memo {
                        self.memo = memo
                    }
                case .transfer(let data):
                    self.address = data.recipientData.recipient.address
                    if let memo = data.recipientData.recipient.memo {
                        self.memo = memo
                    }
                    self.transferData = data
                    return
                }
            } catch {
                NSLog("getTransferDataFromScan error: \(error)")
            }
        case .memo:
            memo = result
        }
        
        if !model.showMemo {
            next()
        }
    }
    
    func paste() {
        guard let string = UIPasteboard.general.string else { return }
        self.address = string.trim()
    }
    
    func next() {
        //TODO: Move validation per field on demand
        let recipient: Recipient = {
            if let result = nameResolveState.result {
                return Recipient(name: result.name, address: result.address, memo: memo)
            }
            return Recipient(name: .none, address: address, memo: memo)
        }()
        
        do {
            let transfer = try model.getRecipientData(
                asset: model.asset,
                recipient: recipient
            )
            recipientData = transfer
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
