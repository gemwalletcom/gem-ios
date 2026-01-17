// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Primitives
import Style
import Store
import Localization
import PrimitivesComponents

public struct InAppNotificationsScene: View {
    @State private var model: InAppNotificationsViewModel

    public init(model: InAppNotificationsViewModel) {
        self._model = State(initialValue: model)
    }

    public var body: some View {
        List {
            switch model.state {
            case .loading:
                CenterLoadingView()
            case .noData, .error:
                EmptyContentView(model: model.emptyContentModel)
            case .data(let sections):
                ForEach(sections) { section in
                    Section(header: section.title.map { Text($0) }) {
                        ForEach(section.values) { itemModel in
                            ListItemView(model: itemModel.listItemModel)
                        }
                    }
                }
                .listRowInsets(.assetListRowInsets)
            }
        }
        .listSectionSpacing(.compact)
        .navigationTitle(model.title)
        .observeQuery(request: $model.request, value: $model.notifications)
        .onChange(of: model.notifications) { model.updateState() }
        .task { await model.update() }
    }
}
