import SwiftUI
import Components
import Style
import Blockchain
import Primitives
import Keystore
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
                    .presentationDetents([.medium, .large])
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
                    ListItemView(title: model.slippageField, subtitle: slippage)
                }
            } header: {
                HStack {
                    Spacer(minLength: 0)
                    TransactionHeaderView(type: model.headerType)
                        .padding(.bottom, .medium)
                    Spacer(minLength: 0)
                }
                .headerProminence(.increased)
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
        .listSectionSpacing(.compact)
        .sheet(item: $isPresentingInfoSheet) {
            InfoSheetScene(model: InfoSheetViewModel(type: $0))
        }
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

// MARK: - Previews

#Preview {
    ConfirmTransferScene(model: .init(
        wallet: .main,
        keystore: LocalKeystore.main,
        data: .main,
        service: ChainServiceFactory(nodeProvider: NodeService.main).service(for: .bitcoin),
        scanService: .main,
        walletsService: .main,
        onComplete: { }
    ))
}
