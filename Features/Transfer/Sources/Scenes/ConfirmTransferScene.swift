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
    private func rowContent(_ content: TransferListItem) -> some View {
        switch content {
        case let .common(commonItem):
            CommonListItemView(item: commonItem)
                .ifLet(commonItem.contextMenu) { view, menu in
                    view.contextMenu(menu.items)
                }
            
        case let .memo(text):
            MemoListItemView(memo: text)
            
        case let .selectableFee(title, value, fiat, onSelect):
            NavigationCustomLink(
                with: ListItemView(
                    title: title,
                    subtitle: value,
                    subtitleExtra: fiat,
                    placeholders: value == nil ? [.subtitle] : [],
                    infoAction: model.onSelectNetworkFeeInfo
                ),
                action: { @MainActor @Sendable in onSelect?() }
            )
            
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
