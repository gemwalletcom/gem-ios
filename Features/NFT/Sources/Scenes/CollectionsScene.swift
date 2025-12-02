// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import GRDBQuery
import Primitives
import Store
import Components
import Style
import PrimitivesComponents

public struct CollectionsScene<ViewModel: CollectionsViewable>: View {
    @State private var model: ViewModel

    public init(model: ViewModel) {
        _model = State(initialValue: model)
    }

    public var body: some View {
        ScrollView {
            LazyVGrid(columns: model.columns) {
                collectionsView
            }
            .padding(.horizontal, Spacing.medium)
        }
        .observeQuery(request: $model.request, value: $model.nftDataList)
        .overlay {
            if model.items.isEmpty {
                EmptyContentView(model: model.emptyContentModel)
            }
        }
        .background { Colors.insetGroupedListStyle.ignoresSafeArea() }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(model.title)
        .refreshable { await model.fetch() }
        .task { await model.fetch() }
    }
}

// MARK: - UI

extension CollectionsScene {
    private var collectionsView: some View {
        ForEach(model.items) { item in
            NavigationLink(value: item.destination) {
                GridPosterView(
                    assetImage: item.assetImage,
                    title: item.title,
                    count: item.count
                )
            }
        }
    }
}
