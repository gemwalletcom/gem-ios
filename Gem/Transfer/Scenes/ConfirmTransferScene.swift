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
    @State var model: ConfirmTransferViewModel

    var body: some View {
        VStack {
            transactionsList
            Spacer()
            StateButton(
                text: model.buttonTitle,
                viewState: model.state,
                image: statefullButtonImage,
                disabledRule: model.shouldDisableButton,
                action: model.onAction
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
            action: model.onChangeFeePriority
        )
        .taskOnce { model.fetch() }
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
                            .url(title: websiteValue, onOpen: { model.isPresentingUrl = model.websiteURL })
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
                        .url(title: model.senderExplorerText, onOpen: { model.isPresentingUrl = model.senderAddressExplorerUrl })
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
                        infoAction: model.onSlippageInto
                    )
                }
            }

            Section {
                if model.shouldShowFeeRatesSelector {
                    NavigationCustomLink(
                        with: networkFeeView,
                        action: model.onSelectFeePicker
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
        .sheet(item: $model.isPresentingInfoSheet) {
            InfoSheetScene(model: InfoSheetViewModel(type: $0))
        }
        .safariSheet(url: $model.isPresentingUrl)
    }

    private var networkFeeView: some  View {
        ListItemView(
            title: model.networkFeeTitle,
            subtitle: model.networkFeeValue,
            subtitleExtra: model.networkFeeFiatValue,
            placeholders: [.subtitle],
            infoAction: model.onNetworkFeeInfo
        )
    }
}
