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
import Localization

public struct TransactionScene: View {
    @State private var model: TransactionDetailViewModel

    public init(model: TransactionDetailViewModel) {
        _model = State(initialValue: model)
    }

    public var body: some View {
        List {
            TransactionHeaderListItemView(
                headerType: model.headerType,
                showClearHeader: model.showClearHeader,
                action: model.onSelectTransactionHeader
            )
            
            SectionListView(
                sections: model.sections,
                listItemView: listItemView(_:)
            )
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
            InfoSheetScene(type: $0)
        }
        .observeQuery(request: $model.request, value: $model.transactionExtended)
        .onChange(of: model.transactionExtended, model.onChangeTransaction)
    }
    
    @ViewBuilder
    private func listItemView(_ item: TransactionListItem) -> some View {
        switch item {
        case .date:
            ListItemView(
                title: model.dateField,
                subtitle: model.date
            )
            
        case .network:
            ListItemImageView(
                title: model.networkField,
                subtitle: model.network,
                assetImage: model.networkAssetImage
            )
            
        case .provider:
            if let viewModel = model.model(for: item) as? ProviderListItemViewModel {
                ProviderListItemView(model: viewModel)
            }
            
        case .status:
            if let viewModel = model.model(for: item) as? StatusListItemViewModel {
                StatusListItemView(model: viewModel)
            }
            
        case .sender, .recipient, .contract, .validator:
            if let viewModel = model.model(for: item) as? AddressListItemViewModel {
                AddressListItemView(model: viewModel)
            }
            
        case .memo:
            if let memo = model.model(for: item) as? String {
                MemoListItemView(memo: memo)
            }
            
        case .fee:
            if let viewModel = model.model(for: item) as? FeeListItemViewModel {
                FeeListItemView(model: viewModel)
            }
            
        case .explorerLink:
            SafariNavigationLink(url: model.transactionExplorerUrl) {
                Text(model.transactionExplorerText)
                    .tint(Colors.black)
            }
            
        case .swapAgainButton:
            StateButton(
                text: model.swapAgain,
                type: .primary(.normal),
                action: model.onSelectTransactionHeader
            )
            .cleanListRow(topOffset: .zero)
        }
    }
}
