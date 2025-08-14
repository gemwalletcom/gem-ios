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
                rowContent: rowContent(_:)
            )
        }
        .contentMargins([.top], .small, for: .scrollContent)
        .listSectionSpacing(.compact)
    }
    
    @ViewBuilder
    private func rowContent(_ content: TransferItemContent) -> some View {
        switch content {
        case let .common(commonItem):
            switch commonItem {
            case let .standard(title: title, subtitle: subtitle, image: image, contextMenu: contextMenu):
                let view = ListItemImageView(
                    title: title,
                    subtitle: subtitle,
                    assetImage: image
                )
                
                if let contextMenu = contextMenu {
                    view.contextMenu(contextMenu.items)
                } else {
                    view
                }
                
            case let .error(title: title, error: error, action: action):
                ListItemErrorView(
                    errorTitle: title,
                    error: error,
                    infoAction: action
                )
                
            case let .text(text):
                MemoListItemView(memo: text)
            }
            
        case let .network(title: title, name: name, image: image):
            ListItemImageView(
                title: title,
                subtitle: name,
                assetImage: image
            )
            
        case let .fee(title: title, value: value, fiatValue: fiatValue, selectable: selectable):
            let feeView = ListItemView(
                title: title,
                subtitle: value,
                subtitleExtra: fiatValue,
                placeholders: value == nil ? [.subtitle] : [],
                infoAction: model.onSelectNetworkFeeInfo
            )
            
            if selectable {
                NavigationCustomLink(
                    with: feeView,
                    action: model.onSelectFeePicker
                )
            } else {
                feeView
            }
            
        case let .address(viewModel):
            AddressListItemView(model: viewModel)
            
        case let .swapDetails(viewModel):
            NavigationCustomLink(
                with: SwapDetailsListView(model: viewModel),
                action: model.onSelectSwapDetails
            )
        }
    }
}
