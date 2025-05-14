import SwiftUI
import Components
import Style
import Blockchain
import Primitives
import Localization
import ChainService
import InfoSheet
import Transfer
import NodeService
import PrimitivesComponents

struct ConfirmTransferScene: View {
    @Environment(\.dismiss) private var dismiss

    @State var model: ConfirmTransferViewModel
    @State private var isPresentingInfoSheet: InfoSheetType? = .none
    @State private var isPresentingUrl: URL? = nil

    var body: some View {
        VStack {
            transactionsList
            Spacer()
            StateButton(
                text: model.buttonTitle,
                viewState: model.state,
                image: statefullButtonImage,
                disabledRule: model.shouldDisableButton,
                action: onAction
            )
            .frame(maxWidth: .scene.button.maxWidth)
        }
        .padding(.bottom, .scene.bottom)
        .background(Colors.grayBackground)
        .frame(maxWidth: .infinity)
        .activityIndicator(isLoading: model.confirmingState.isLoading, message: model.progressMessage)
        .navigationTitle(model.title)
        .debounce(
            value: model.feeModel.priority,
            interval: nil,
            action: onChangeFeePriority
        )
        .taskOnce { fetch() }
        .sheet(isPresented: $model.isPresentedNetworkFeePicker) {
            NavigationStack {
                NetworkFeeScene(model: model.feeModel)
                    .presentationDetentsForCurrentDeviceSize(expandable: true)
            }
        }
        .alert(item: $model.confirmingErrorMessage) {
            Alert(title: Text(Localized.Errors.transferError), message: Text($0))
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

    private var transactionsList: some View {
        List {
            TransactionHeaderListItemView(
                headerType: model.headerType,
                showClearHeader: model.showClearHeader
            )
            Section {
                if let appValue = model.appValue {
                    ListItemImageView(
                        title: model.appTitle,
                        subtitle: appValue,
                        assetImage: model.appAssetImage
                    )
                }

                if let websiteValue = model.websiteValue {
                    ListItemView(title: model.websiteTitle, subtitle: websiteValue)
                        .contextMenu(
                            .url(title: websiteValue, onOpen: { isPresentingUrl = model.websiteURL })
                        )
                }

                ListItemImageView(
                    title: model.senderTitle,
                    subtitle: model.senderValue,
                    assetImage: model.senderAssetImage
                )
                .contextMenu(
                    [
                        .copy(value: model.senderAddress),
                        .url(title: model.senderExplorerText, onOpen: { isPresentingUrl = model.senderAddressExplorerUrl })
                    ]
                )

                ListItemImageView(
                    title: model.networkTitle,
                    subtitle: model.networkValue,
                    assetImage: model.networkAssetImage
                )
                
                if model.shouldShowRecipientField {
                    AddressListItemView(model: model.recipientAddressViewModel)
                }

                if model.shouldShowMemo {
                    MemoListItemView(memo: model.memo)
                }
                
                if let slippage = model.slippageText {
                    ListItemView(
                        title: model.slippageField,
                        subtitle: slippage,
                        infoAction: onSlippageInto
                    )
                }
            }

            Section {
                if model.shouldShowFeeRatesSelector {
                    NavigationCustomLink(
                        with: networkFeeView,
                        action: onSelectFeePicker
                    )
                } else {
                    networkFeeView
                }
            } footer: {
                if let footer = model.networkFeeFooterText {
                    Text(footer)
                }
            }

            if case let .error(error) = model.state {
                ListItemErrorView(errorTitle: Localized.Errors.errorOccured, error: error)
            }
        }
        .contentMargins([.top], .small, for: .scrollContent)
        .listSectionSpacing(.compact)
        .sheet(item: $isPresentingInfoSheet) {
            InfoSheetScene(model: InfoSheetViewModel(type: $0))
        }
        .safariSheet(url: $isPresentingUrl)
    }

    private var networkFeeView: some  View {
        ListItemView(
            title: model.networkFeeTitle,
            subtitle: model.networkFeeValue,
            subtitleExtra: model.networkFeeFiatValue,
            placeholders: [.subtitle],
            infoAction: onNetworkFeeInfo
        )
    }
}

// MARK: - Actions

extension ConfirmTransferScene {
    private func onSelectConfirmTransfer() {
        guard let value = model.state.value,
              let input = value.input,
              case .amount(let amount) = value.transferAmountResult else { return }
        process(input: input, amount: amount)
    }

    private func onSelectFeePicker() {
        model.isPresentedNetworkFeePicker.toggle()
    }

    private func onChangeFeePriority(_ priority: FeePriority) async {
        await model.fetch()
    }

    private func onAction() {
        if model.state.isError {
            fetch()
        } else {
            onSelectConfirmTransfer()
        }
    }

    private func onNetworkFeeInfo() {
        isPresentingInfoSheet = .networkFee(model.dataModel.chain)
    }
    
    private func onSlippageInto() {
        isPresentingInfoSheet = .slippage
    }
}

// MARK: - Effects

extension ConfirmTransferScene {
    private func fetch() {
        Task {
            await model.fetch()
        }
    }

    private func process(input: TransactionLoad, amount: TransferAmount) {
        Task {
            await model.process(input: input, amount: amount)
            await MainActor.run {
                if case .data(_) = model.confirmingState {
                    model.onCompleteAction()
                }
            }
        }
    }
}
