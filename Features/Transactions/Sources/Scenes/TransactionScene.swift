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
    private let model: TransactionSceneViewModel

    public init(model: TransactionSceneViewModel) {
        self.model = model
    }

    public var body: some View {
        List {
            ForEach(model.sections) { section in
                Section {
                    ForEach(section.values) { item in
                        itemView(for: item)
                    }
                }
            }
        }
        .contentMargins([.top], .small, for: .scrollContent)
        .listSectionSpacing(.compact)
        .background(Colors.grayBackground)
        .navigationTitle(model.title)
    }

    @ViewBuilder
    private func itemView(for item: TransactionItem) -> some View {
        let itemModel = model.itemModel(for: item)
        switch itemModel {
        case .listItem(let listItemType):
            ListItemView(type: listItemType)
        case .header(let model):
            TransactionHeaderListItemView(
                model: model,
                action: self.model.onSelectTransactionHeader
            )
        case .participant(let model):
            AddressListItemView(model: model.addressViewModel)
        case .explorer(let url, let text):
            SafariNavigationLink(url: url) {
                Text(text)
                    .tint(Colors.black)
            }
        case .swapButton(let text, let url):
            StateButton(
                text: text,
                type: .primary(.normal),
                action: self.model.onSelectTransactionHeader
            )
            .cleanListRow(topOffset: .zero)
        case .empty:
            EmptyView()
        }
        }
}
