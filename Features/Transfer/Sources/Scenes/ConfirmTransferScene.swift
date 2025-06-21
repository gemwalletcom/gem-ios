// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Style
import Localization
import InfoSheet
import PrimitivesComponents

public struct ConfirmTransferScene: View {
    @State private var model: ConfirmTransferViewModel

    public init(model: ConfirmTransferViewModel) {
        _model = State(initialValue: model)
    }

    public var body: some View {
        VStack {
            transactionsList
            Spacer()
            StateButton(
                text: model.buttonTitle,
                viewState: model.state,
                image: statefullButtonImage,
                disabledRule: model.shouldDisableButton,
                action: model.onSelectConfirmButton
            )
            .frame(maxWidth: .scene.button.maxWidth)
        }
        .padding(.bottom, .scene.bottom)
        .background(Colors.grayBackground)
        .frame(maxWidth: .infinity)
        .debounce(
            value: model.feeModel.priority,
            interval: nil,
            action: model.onChangeFeePriority
        )
        .taskOnce { model.fetch() }
        .navigationTitle(model.title)
        // TODO: - move to navigation view
        .navigationBarTitleDisplayMode(.inline)
        .activityIndicator(isLoading: model.confirmingState.isLoading, message: model.progressMessage)
        .sheet(item: $model.isPresentingSheet) {
            switch $0 {
            case let .info(type):
                InfoSheetScene(model: InfoSheetViewModel(type: type))
            case let .url(url):
                SFSafariView(url: url)
            case .networkFeeSelector:
                NavigationStack {
                    NetworkFeeScene(model: model.feeModel)
                        .presentationDetentsForCurrentDeviceSize(expandable: true)
                }
            }
        }
        .alert(
            Localized.Errors.transferError,
            isPresented: $model.isPresentingErrorMessage.mappedToBool(),
            actions: {},
            message: {
                Text(model.isPresentingErrorMessage ?? "")
            }
        )
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
                            .url(title: websiteValue, onOpen: model.onSelectOpenWebsiteURL)
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
                        .url(title: model.senderExplorerText, onOpen: model.onSelectOpenSenderAddressURL)
                    ]
                )

                ListItemImageView(
                    title: model.networkTitle,
                    subtitle: model.networkValue,
                    assetImage: model.networkAssetImage
                )
                
                if model.shouldShowRecipient {
                    AddressListItemView(model: model.recipientAddressViewModel)
                }

                if model.shouldShowMemo {
                    MemoListItemView(memo: model.memo)
                }
                
                if let slippage = model.slippageText {
                    ListItemView(
                        title: model.slippageField,
                        subtitle: slippage,
                        infoAction: model.onSelectSlippageInfo
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
    }

    private var networkFeeView: some  View {
        ListItemView(
            title: model.networkFeeTitle,
            subtitle: model.networkFeeValue,
            subtitleExtra: model.networkFeeFiatValue,
            placeholders: [.subtitle],
            infoAction: model.onSelectNetworkFeeInfo
        )
    }
}
