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

    private static let networkFeeItemHeight: CGFloat = 38.0

    var body: some View {
        VStack {
            List {
                transactionSection(value: model.state.value)
            }
            Spacer()
            StatefullButton(
                text: model.buttonTitle,
                viewState: model.state,
                image: statefullButtonImage,
                action: model.state.isError ? onSelectTryAgain : onSelectConfirmTransfer
            )
            .disabled(model.shouldDisalbeButton)
            .frame(maxWidth: Spacing.scene.button.maxWidth)
        }
        .padding(.bottom, Spacing.scene.bottom)
        .background(Colors.grayBackground)
        .frame(maxWidth: .infinity)
        .navigationTitle(model.title)
        .alert(item: $isPresentingErrorMessage) {
            Alert(title: Text("Transfer Error"), message: Text($0))
        }
        .modifier(activityIndicator(isLoading: isLoading))
        .taskOnce {
            fetch()
        }
    }
}

// MARK: - UI Components

extension ConfirmTransferScene {

    private var statefullButtonImage: Image? {
        if let image = model.buttonImage {
            return Image(systemName: image)
        }
        return nil
    }

    private func transactionSection(value: TransactionInputViewModel?) -> some View {
        Section {
            if let appValue = model.appValue {
                ListItemView(title: model.appTitle, subtitle: appValue)
            }

            if let websiteValue = model.websiteValue {
                ListItemView(title: model.websiteTitle, subtitle: websiteValue)
                    .contextMenu {
                        if let websiteURL = model.websiteURL {
                            ContextMenuViewURL(title: websiteValue, url: websiteURL, image: SystemImage.network)
                        }
                    }
            }

            ListItemView(title: model.senderTitle, subtitle: model.senderValue)
                .contextMenu {
                    ContextMenuCopy(title: Localized.Common.copy, value: model.senderAddress)
                    ContextMenuViewURL(title: model.senderExplorerText, url: model.senderAddressExplorerUrl, image: SystemImage.globe)
                }

            if model.shouldShowRecipientField {
                AddressListItem(title: model.recipientTitle, style: .full, account: model.recipientValue)
            }

            if model.shouldShowMemo {
                MemoListItem(memo: model.memo)
            }

            HStack {
                ListItemView(title: model.networkTitle, subtitle: model.networkValue)
                AssetImageView(assetImage: model.networkAssetImage, size: Sizing.list.image)
            }

            ListItemView(
                title: model.networkFeeTitle,
                subtitle: model.networkFeeValue,
                subtitleExtra: model.networkFeeFiatValue,
                placeholders: [.subtitle]
            )
            .frame(height: ConfirmTransferScene.networkFeeItemHeight)
            .id(UUID())
        } header: {
            HStack {
                Spacer(minLength: 0)
                TransactionHeaderView(type: model.headerType)
                    .padding(.bottom, 16)
                Spacer(minLength: 0)
            }
            .headerProminence(.increased)
        } footer: {
            if case let .error(error) = model.state {
                ListItemErrorView(errorTitle: Localized.Errors.errorOccured, error: error)
            }
        }
    }

    private func activityIndicator(isLoading: Bool) -> some ViewModifier {
        ActivityIndicatorModifier(message: Localized.Common.loading, isLoading: isLoading)
    }
}

// MARK: - Actions

extension ConfirmTransferScene {
    private func onSelectConfirmTransfer() {
        guard let value = model.state.value,
              case .amount(let amount) = value.transferAmountResult,
        let input = value.input else { return }
        Task {
            await processNext(input: input, amount: amount)
        }
    }

    private func onSelectTryAgain() {
        fetch()
    }
}

// MARK: - Effects

extension ConfirmTransferScene {
    private func fetch() {
        Task {
            await model.fetch()
        }
    }

    @MainActor
    private func processNext(input: TransactionPreload, amount: TranferAmount) async {
        isLoading = true
        do {
            let data = try await model.sign(transferData: model.data, input: input, amount: amount)
            let hash = try await model.broadcast(data: data, options: model.broadcastOptions)
            let transaction = try model.getTransaction(input: input, amount: amount, hash: hash)

            try model.addTransaction(transaction: transaction)
            isLoading = false
            // TODO: - that's crazy, TODO for later
            for _ in 0..<model.dismissAmount {
                dismiss()
            }
        } catch {
            isLoading = false
            isPresentingErrorMessage = error.localizedDescription
            NSLog("confirm transaction error \(error)")
        }
    }
}
