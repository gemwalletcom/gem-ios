// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import GRDBQuery
import Primitives
import Store
import Components
import Style
import Localization
import PrimitivesComponents

public struct CollectionsScene<ViewModel: CollectionsViewable>: View {
    @State private var model: ViewModel

    public init(model: ViewModel) {
        _model = State(initialValue: model)
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: Spacing.medium) {
                LazyVGrid(columns: model.columns) {
                    gridItemsView
                }

                if let unverifiedCount = model.content.unverifiedCount {
                    unverifiedSection(unverifiedCount)
                }
                Spacer()
            }
            .padding(.horizontal, .medium)
        }
        .observeQuery(request: $model.request, value: $model.nftDataList)
        .overlay {
            if model.content.items.isEmpty {
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
    private var gridItemsView: some View {
        ForEach(model.content.items) { gridItem in
            NavigationLink(value: gridItem.destination) {
                GridPosterView(
                    assetImage: gridItem.assetImage,
                    title: gridItem.title
                )
            }
        }
    }

    private func unverifiedSection(_ count: String) -> some View {
        NavigationLink(value: Scenes.UnverifiedCollections()) {
            HStack {
                ListItemView(
                    title: Localized.Asset.Verification.unverified,
                    subtitle: count,
                    imageStyle: .list(assetImage: .image(Images.TokenStatus.warning))
                )
                Spacer()
                Images.System.chevronRight
                    .foregroundColor(Colors.gray)
            }
        }
    }
}
