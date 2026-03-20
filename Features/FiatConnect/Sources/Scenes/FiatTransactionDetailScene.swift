// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Style
import PrimitivesComponents

public struct FiatTransactionDetailScene: View {
    @State private var model: FiatTransactionDetailViewModel

    public init(model: FiatTransactionDetailViewModel) {
        _model = State(initialValue: model)
    }

    public var body: some View {
        List {
            TransactionHeaderListItemView(model: model.headerModel)

            ForEach(model.sections) { section in
                Section {
                    ForEach(section.values) { item in
                        content(for: model.item(for: item))
                    }
                }
            }
        }
        .contentMargins([.top], .small, for: .scrollContent)
        .listSectionSpacing(.compact)
        .background(Colors.grayBackground)
        .bindQuery(model.query)
        .navigationTitle(model.title)
    }

    @ViewBuilder
    private func content(for itemModel: FiatTransactionDetailItemModel) -> some View {
        switch itemModel {
        case let .listItem(model):
            ListItemView(model: model)
        case let .listImageItem(title, subtitle, image):
            ListItemImageView(title: title, subtitle: subtitle, assetImage: image)
        case let .explorer(url, text):
            SafariNavigationLink(url: url) {
                Text(text)
                    .tint(Colors.black)
            }
        case .empty:
            EmptyView()
        }
    }
}
