// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Style
import Localization
import InfoSheet
import FiatConnect
import Swap
import PrimitivesComponents

public struct ConfirmTransferScene: View {
    @State private var model: ConfirmTransferSceneViewModel

    public init(model: ConfirmTransferSceneViewModel) {
        _model = State(initialValue: model)
    }

    public var body: some View {
        VStack {
            transactionsList
            Spacer()
            StateButton(model.confirmButtonModel)
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

    private var transactionsList: some View {
        List {
            TransactionHeaderListItemView(
                headerType: model.headerType,
                showClearHeader: model.showClearHeader
            )
            SectionListView(
                sections: model.listSections,
                listItemView: listItemView(_:)
            )
        }
        .contentMargins([.top], .small, for: .scrollContent)
        .listSectionSpacing(.compact)
    }
    
    @ViewBuilder
    private func listItemView(_ item: TransferListItem) -> some View {
        switch item {
        case .app:
            if let appText = model.appText {
                ListItemImageView(
                    title: model.appTitle,
                    subtitle: appText,
                    assetImage: model.appAssetImage
                )
                .contextMenu([
                    .url(title: model.websiteTitle, onOpen: model.onSelectOpenWebsiteURL)
                ])
            }
            
        case .sender:
            ListItemImageView(
                title: model.senderTitle,
                subtitle: model.senderValue,
                assetImage: model.senderAssetImage
            )
            .contextMenu([
                .copy(value: model.senderAddress),
                .url(title: model.senderExplorerText, onOpen: model.onSelectOpenSenderAddressURL)
            ])
            
        case .network:
            ListItemImageView(
                title: model.networkTitle,
                subtitle: model.networkText,
                assetImage: model.networkAssetImage
            )
        case .address:
            if let viewModel = model.model(for: item) as? AddressListItemViewModel {
                AddressListItemView(model: viewModel)
            }
            
        case .memo:
            if let memo = model.model(for: item) as? String {
                MemoListItemView(memo: memo)
            }
            
        case .swapDetails:
            if let viewModel = model.model(for: item) as? SwapDetailsViewModel {
                NavigationCustomLink(
                    with: SwapDetailsListView(model: viewModel),
                    action: model.onSelectSwapDetails
                )
            }
            
        case .fee:
            if let viewModel = model.model(for: item) as? FeeListItemViewModel {
                if let onSelect = viewModel.onSelect {
                    NavigationCustomLink(
                        with: FeeListItemView(model: viewModel),
                        action: { @Sendable @MainActor in onSelect() }
                    )
                } else {
                    FeeListItemView(model: viewModel)
                }
            }
            
        case .error:
            if let error = model.listError {
                ListItemErrorView(
                    errorTitle: model.listErrorTitle,
                    error: error,
                    infoAction: { model.onSelectListError(error: error) }
                )
            }
        }
    }
}
