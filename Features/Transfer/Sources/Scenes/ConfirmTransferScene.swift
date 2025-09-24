// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Style
import Localization
import InfoSheet
import PrimitivesComponents
import FiatConnect
import Swap

public struct ConfirmTransferScene: View {
    @State private var model: ConfirmTransferSceneViewModel

    public init(model: ConfirmTransferSceneViewModel) {
        _model = State(initialValue: model)
    }

    public var body: some View {
        ListSectionView(
            provider: model,
            content: content(for:)
        )
        .contentMargins([.top], .small, for: .scrollContent)
        .listSectionSpacing(.compact)
        .safeAreaView {
            StateButton(model.confirmButtonModel)
                .frame(maxWidth: .scene.button.maxWidth)
                .padding(.bottom, .scene.bottom)
        }
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
            case .info(let type):
                InfoSheetScene(type: type)
            case .url(let url):
                SFSafariView(url: url)
            case .networkFeeSelector:
                NavigationStack {
                    NetworkFeeScene(model: model.feeModel)
                        .presentationDetentsForCurrentDeviceSize(expandable: true)
                }
            case .fiatConnect(let assetAddress, let walletId):
                NavigationStack {
                    FiatConnectNavigationView(
                        model: FiatSceneViewModel(
                            assetAddress: assetAddress,
                            walletId: walletId.id
                        )
                    )
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarDismissItem(
                            title: .done,
                            placement: .topBarLeading
                        )
                    }
                }
            case .swapDetails:
                if let swapDetailsViewModel = model.swapDetailsViewModel {
                    NavigationStack {
                        SwapDetailsView(model: Bindable(swapDetailsViewModel))
                            .presentationDetentsForCurrentDeviceSize(expandable: true)
                    }
                }
            }
        }
        .alertSheet($model.isPresentingAlertMessage)
    }
}

// MARK: - UI Components

extension ConfirmTransferScene {

    @ViewBuilder
    private func content(for itemModel: ConfirmTransferItemModel) -> some View {
        switch itemModel {
        case let .header(model):
            TransactionHeaderListItemView(
                headerType: model.headerType,
                showClearHeader: model.showClearHeader
            )
        case let .app(model):
            ListItemImageView(model: model)
                .contextMenu(
                    .url(title: self.model.websiteTitle, onOpen: self.model.onSelectOpenWebsiteURL)
                )
        case let .sender(model):
            ListItemImageView(model:model)
                .contextMenu([
                        .copy(value: self.model.senderAddress),
                        .url(title: self.model.senderExplorerText, onOpen: self.model.onSelectOpenSenderAddressURL)
                    ])
        case .participant: fatalError("TODO")
        case .network(let title, let subtitle, let image): fatalError("TODO")
        case .swapDetails(let swapDetailsViewModel): fatalError("TODO")
        case .networkFee(let listItemModel, let isSelectable): fatalError("TODO")
        case .error(let title, let error, let onInfoAction): fatalError("TODO")
        case let .listItem(model): fatalError("TODO")
        case .empty: fatalError("TODO")
        }
    }

    // LEGACY:
    private var transactionsList: some View {
        List {
            /* DONE
            TransactionHeaderListItemView(
                headerType: model.headerType,
                showClearHeader: model.showClearHeader
            )
             */
            Section {
                /* DONE
                if let appText = model.appText {
                    ListItemImageView(
                        title: model.appTitle,
                        subtitle: appText,
                        assetImage: model.appAssetImage
                    )
                    .contextMenu(
                        .url(title: model.websiteTitle, onOpen: model.onSelectOpenWebsiteURL)
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
                 */

                ListItemImageView(
                    title: model.networkTitle,
                    subtitle: model.networkText,
                    assetImage: model.networkAssetImage
                )
                
                if model.shouldShowRecipient {
                    AddressListItemView(model: model.recipientAddressViewModel)
                }

                if model.shouldShowMemo {
                    MemoListItemView(memo: model.memo)
                }
                
                if let swapDetailsViewModel = model.swapDetailsViewModel {
                    NavigationCustomLink(
                        with: SwapDetailsListView(model: swapDetailsViewModel),
                        action: model.onSelectSwapDetails
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
            }

            if let error = model.listError {
                ListItemErrorView(
                    errorTitle: model.listErrorTitle,
                    error: error,
                    infoAction: {
                        model.onSelectListError(error: error)
                    }
                )
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
