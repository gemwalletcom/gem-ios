// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Components
import Style
import Store
import GRDBQuery
import Primitives
import InfoSheet
import PrimitivesComponents
import ExplorerService

public struct TransactionScene: View {
    @State private var model: TransactionDetailViewModel

    public init(model: TransactionDetailViewModel) {
        _model = State(initialValue: model)
    }

    public var body: some View {
        VStack {
            List {
                TransactionHeaderListItemView(
                    headerType: model.headerType,
                    showClearHeader: model.showClearHeader,
                    action: model.onSelectTransactionHeader
                )

                if model.showSwapAgain {
                    Section {
                        StateButton(
                            text: model.swapAgain,
                            type: .primary(.normal),
                            action: model.onSelectTransactionHeader
                        )
                    }
                    .cleanListRow(topOffset: .zero)
                }

                Section {
                    ListItemView(title: model.dateField, subtitle: model.date)
                    HStack(spacing: .small) {
                        ListItemView(
                            title: model.statusField,
                            subtitle: model.statusText,
                            subtitleStyle: model.statusTextStyle,
                            infoAction: model.onStatusInfo
                        )
                        switch model.statusType {
                        case .none:
                            EmptyView()
                        case .progressView:
                            LoadingView(tint: Colors.orange)
                        case .image(let image):
                            image
                        }
                    }

                    if let recipientAddressViewModel = model.recipientAddressViewModel {
                        AddressListItemView(model: recipientAddressViewModel)
                    }

                    if model.showMemoField {
                        MemoListItemView(memo: model.memo)
                    }

                    ListItemImageView(
                        title: model.networkField,
                        subtitle: model.network,
                        assetImage: model.networkAssetImage
                    )

                    if let item = model.providerListItem {
                        ListItemImageView(
                            title: item.title,
                            subtitle: item.subtitle,
                            assetImage: item.assetImage
                        )
                    }

                    ListItemView(
                        title: model.networkFeeField,
                        subtitle: model.networkFeeText,
                        subtitleExtra: model.networkFeeFiatText,
                        infoAction: model.onNetworkFeeInfo
                    )
                }
                Section {
                    SafariNavigationLink(url: model.transactionExplorerUrl) {
                        Text(model.transactionExplorerText)
                            .tint(Colors.black)
                    }
                }
            }
            .contentMargins([.top], .small, for: .scrollContent)
            .listSectionSpacing(.compact)
            .background(Colors.grayBackground)
            .navigationTitle(model.title)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        model.onSelectShare()
                    } label: {
                        Images.System.share
                    }
                }
            }
            .sheet(isPresented: $model.isPresentingShareSheet) {
                ShareSheet(activityItems: [model.transactionExplorerUrl.absoluteString])
            }
            .sheet(item: $model.isPresentingInfoSheet) {
                InfoSheetScene(model: InfoSheetViewModel(type: $0))
            }
        }
        .observeQuery(request: $model.request, value: $model.transactionExtended)
        .onChange(of: model.transactionExtended, model.onChangeTransaction)
    }
}
