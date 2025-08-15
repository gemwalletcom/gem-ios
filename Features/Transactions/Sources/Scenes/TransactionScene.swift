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
        List {
            TransactionHeaderListItemView(
                headerType: model.headerType,
                showClearHeader: model.showClearHeader,
                action: model.onSelectTransactionHeader
            )
            
            SectionListView(
                sections: model.listSections,
                rowContent: rowContent(_:)
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
    private func rowContent(_ content: TransactionListItem) -> some View {
        switch content {
        case let .common(commonItem):
            CommonListItemView(item: commonItem)
                .ifLet(commonItem.contextMenu) { view, menu in
                    view.contextMenu(menu.items)
                }
            
        case let .memo(text):
            MemoListItemView(memo: text)
            
        case let .status(title, value, style, showProgressView, infoAction):
            HStack(spacing: Spacing.small) {
                ListItemView(
                    title: title,
                    subtitle: value,
                    subtitleStyle: style,
                    infoAction: infoAction
                )
                if showProgressView {
                    LoadingView(tint: Colors.orange)
                }
            }
            
        case let .address(viewModel):
            AddressListItemView(model: viewModel)
            
        case let .explorerLink(text, url):
            SafariNavigationLink(url: url) {
                Text(text)
                    .tint(Colors.black)
            }
            
        case let .swapButton(text, action):
            StateButton(
                text: text,
                type: .primary(.normal),
                action: action ?? {}
            )
            .cleanListRow(topOffset: .zero)
        }
    }
}
