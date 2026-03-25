// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Style
import Localization
import PrimitivesComponents
import Swap
import Primitives

public struct ConfirmTransferScene: View {
    @Bindable var model: ConfirmTransferSceneViewModel

    public init(model: ConfirmTransferSceneViewModel) {
        self.model = model
    }

    public var body: some View {
        ListSectionView(
            provider: model,
            content: content(for:)
        )
        .contentMargins([.top], .small, for: .scrollContent)
        .listSectionSpacing(.compact)
        .safeAreaButton {
            StateButton(model.confirmButtonModel)
        }
        .frame(maxWidth: .infinity)
        .debounce(
            value: model.feeModel.priority,
            interval: .none,
            action: model.onChangeFeePriority
        )
        .taskOnce { model.fetch() }
        .navigationTitle(model.title)
        .navigationBarTitleDisplayMode(.inline)
        .activityIndicator(isLoading: model.confirmingState.isLoading, message: model.progressMessage)
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
            ListItemImageView(model: model)
                .explorerContext(self.model.senderExplorerContext)
        case let .recipient(model):
            AddressListItemView(model: model)
        case let .network(model):
            ListItemImageView(model: model)
        case let .memo(model):
            ListItemView(model: model)
                .contextMenu( model.subtitle.map ({ [.copy(value: $0)] }) ?? [] )
        case .swapDetails(let model):
            NavigationCustomLink(
                with: SwapDetailsListView(model: model),
                action: { self.model.onSelectSwapDetails() }
            )
        case .perpetualDetails(let model):
            NavigationCustomLink(
                with: ListItemView(model: model.listItemModel),
                action: { self.model.onSelectPerpetualDetails(model) }
            )
        case .perpetualModifyPosition(let model):
            ListItemView(model: model.listItemModel)
        case let .networkFee(model, selectable):
            if selectable {
                NavigationCustomLink(
                    with: ListItemView(model: model),
                    action: self.model.onSelectFeePicker
                )
            } else {
                ListItemView(model: model)
            }
        case let .warnings(warnings):
            SimulationWarningsContent(warnings: warnings)
        case let .payload(fields):
            Group {
                SimulationPayloadFieldsContent(
                    fields: fields,
                    fieldViewModel: self.model.payloadFieldViewModel(for:),
                    contextMenuItems: self.model.contextMenuItems(for:)
                )

                if self.model.hasPayloadDetails {
                    NavigationCustomLink(
                        with: ListItemView(title: Localized.Common.details),
                        action: self.model.onSelectPayloadDetails
                    )
                }
            }
        case let .error(title, error, onInfoAction):
            ListItemErrorView(
                errorTitle: title,
                error: error,
                infoAction: onInfoAction
            )
        case .empty:
            EmptyView()
        }
    }
}
