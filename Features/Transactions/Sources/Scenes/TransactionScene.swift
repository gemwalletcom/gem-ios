// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Components
import Style
import PrimitivesComponents

public struct TransactionScene: View {
    private let model: TransactionSceneViewModel

    public init(model: TransactionSceneViewModel) {
        self.model = model
    }

    public var body: some View {
        ListSectionView(provider: model) { itemModel in
            itemView(for: itemModel)
        }
        .contentMargins([.top], .small, for: .scrollContent)
        .listSectionSpacing(.compact)
        .background(Colors.grayBackground)
        .navigationTitle(model.title)
    }

    @ViewBuilder
    private func itemView(for itemModel: TransactionItemModel) -> some View {
        switch itemModel {
        case let .listItem(model):
            ListItemView(model: model)
        case let .header(model):
            TransactionHeaderListItemView(
                model: model,
                action: self.model.onSelectTransactionHeader
            )
        case let .participant(model):
            AddressListItemView(model: model.addressViewModel)
        case let .network(title, subtitle, image):
            ListItemImageView(
                title: title,
                subtitle: subtitle,
                assetImage: image
            )
        case let .explorer(url, text):
            SafariNavigationLink(url: url) {
                Text(text)
                    .tint(Colors.black)
            }
        case let .swapAgain(text):
            StateButton(
                text: text,
                type: .primary(.normal),
                action: model.onSelectTransactionHeader
            )
            .cleanListRow(topOffset: .zero)
        case .empty:
            EmptyView()
        }
    }
}
