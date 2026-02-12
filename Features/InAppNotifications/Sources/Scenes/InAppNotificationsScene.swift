// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Store
import PrimitivesComponents

public struct InAppNotificationsScene: View {
    @State private var model: InAppNotificationsViewModel

    public init(model: InAppNotificationsViewModel) {
        _model = State(initialValue: model)
    }

    public var body: some View {
        List {
            ForEach(model.sections) { section in
                Section(header: section.title.map { Text($0) }) {
                    ForEach(section.values) { itemModel in
                        notificationRow(itemModel)
                    }
                }
            }
            .listRowInsets(.assetListRowInsets)
        }
        .listSectionSpacing(.compact)
        .overlay {
            if model.sections.isEmpty {
                EmptyContentView(model: model.emptyContentModel)
            }
        }
        .navigationTitle(model.title)
        .bindQuery(model.query)
        .task { await model.fetch() }
    }

    @ViewBuilder
    private func notificationRow(_ itemModel: InAppNotificationListItemViewModel) -> some View {
        let view = ListItemView(model: itemModel.listItemModel)
        if let url = itemModel.url {
            NavigationCustomLink(with: view) {
                model.open(url: url)
            }
        } else {
            view
        }
    }
}
