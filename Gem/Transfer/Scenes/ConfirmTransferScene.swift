import SwiftUI
import Components
import Style
import Blockchain
import Primitives

typealias ConfirmTransferDelegate = (Result<String, Error>) -> Void
typealias ConfirmMessageDelegate = (Result<String, Error>) -> Void

struct ConfirmTransferScene: View {

    @Environment(\.dismiss) private var dismiss
    @StateObject var model: ConfirmTransferViewModel
    @State private var isPresentingErrorMessage: String?
    @State private var isLoading: Bool = false
    
    var body: some View {
        VStack {
            switch model.state {
            case .loading:
                StateLoadingView()
            case .noData:
                StateEmptyView(title: "")
            case .error(let error):
                StateErrorView(error: error, message: Localized.Common.tryAgain) {
                    Task { try await model.fetch() }
                }
            case .loaded(let value):
                List {
                    Section {
                        if let app = model.appText {
                            ListItemView(title: Localized.WalletConnect.app, subtitle: app)
                        }
                        if let website = model.website, let websiteText = model.websiteText {
                            ListItemView(title: Localized.WalletConnect.website, subtitle: websiteText)
                                .contextMenu {
                                    ContextMenuViewURL(title: websiteText, url: website, image: SystemImage.network)
                                }
                        }
                        ListItemView(title: model.senderField, subtitle: model.senderText)
                            .contextMenu {
                                ContextMenuCopy(title: Localized.Common.copy, value: model.senderAddress)
                                ContextMenuViewURL(title: model.senderExplorerText, url: model.senderAddressExplorerUrl, image: SystemImage.globe)
                            }
                        AddressListItem(title: model.recipientField, style: .full, account: value.recipientAccount)
                        
                        if value.showMemoField {
                            MemoListItem(memo: value.memo)
                        }
                        HStack {
                            ListItemView(title: model.networkField, subtitle: value.network)
                            AssetImageView(assetImage: model.networkAssetImage, size: Sizing.list.image)
                        }
                        ListItemView(
                            title: model.networkFeeField,
                            subtitle: value.networkFeeText,
                            subtitleExtra: value.networkFeeFiatText
                        )
                    } header: {
                        HStack {
                            Spacer(minLength: 0)
                            TransactionHeaderView(type: value.headerType)
                                .padding(.bottom, 16)
                            Spacer(minLength: 0)
                        }
                    }
                    .headerProminence(.increased)
                }
                switch value.transferAmountResult {
                case .amount(let amount):
                    Button(role: .none) {
                        Task { try await next(input: value.input, amount: amount) }
                    } label: {
                        HStack {
                            Image(systemName: model.buttonImage)
                            Text(model.buttonTitle)
                        }
                    }
                    .buttonStyle(BlueButton())
                    .padding(.bottom, Spacing.scene.bottom)
                    .frame(maxWidth: Spacing.scene.button.maxWidth)
                case .error(_, let error):
                    let title: String = {
                        switch error {
                        case .insufficientBalance(let asset):
                            return Localized.Transfer.insufficientBalance(AssetViewModel(asset: asset).title)
                        case .insufficientNetworkFee(let asset):
                            return Localized.Transfer.insufficientNetworkFeeBalance(AssetViewModel(asset: asset).title)
                        }
                    }()
                    Button(role: .none) {} label: {
                        Text(title)
                    }
                    .buttonStyle(ColorButton.gray())
                    .padding(.bottom, Spacing.scene.bottom)
                    .frame(maxWidth: Spacing.scene.button.maxWidth)
                }
            }
        }
        .background(Colors.grayBackground)
        .navigationTitle(model.title)
        .alert(item: $isPresentingErrorMessage) {
            Alert(title: Text("Transfer Error"), message: Text($0))
        }
        .modifier(
            ActivityIndicatorModifier(message: Localized.Common.loading, isLoading: isLoading)
        )
        .taskOnce {
            Task {
                do {
                    try await model.fetch()
                } catch {
                    NSLog("confirm transfer error \(error)")
                }
            }
        }
    }
    
    func next(input: TransactionPreload, amount: TranferAmount) async throws {
        isLoading = true
        do {
            let data = try await model.sign(transferData: model.data, input: input, amount: amount)
            let hash = try await model.broadcast(data: data, options: model.broadcastOptions)

            let transaction = try model.getTransaction(
                input: input,
                amount: amount,
                hash: hash
            )
            
            try model.addTransaction(transaction: transaction)
            
            // that's crazy, TODO for later
            for _ in (0..<model.dismissAmount) {
                NSLog("print dismiss")
                dismiss()
            }
            
        } catch {
            isPresentingErrorMessage = error.localizedDescription
            
            NSLog("confirm transaction error \(error)")
        }
        isLoading = false
    }
}
