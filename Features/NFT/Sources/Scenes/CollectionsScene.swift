// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import GRDBQuery
import Primitives
import Store
import NFTService
import Components
import DeviceService
import Style
import Localization

public struct CollectionsScene: View {
    private let model: CollectionsViewModel

    @Query<NFTRequest>
    private var nftDataList: [NFTData]
    
    public init(model: CollectionsViewModel) {
        self.model = model
        let request = Binding {
            model.request
        } set: { new in
            model.request = new
        }
        _nftDataList = Query(request)
    }
    
    public var body: some View {
        ScrollView {
            LazyVGrid(columns: model.columns) {
                collectionsView
            }
        }
        .overlay {
            // TODO: - migrate to StateEmptyView + Overlay, when we will have image
            if nftDataList.isEmpty {
                Text(Localized.Activity.EmptyState.message)
                    .textStyle(.body)
            }
        }
        .padding(.horizontal, Spacing.medium)
        .background(Colors.insetGroupedListStyle)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(model.title)
        .refreshable(action: model.fetch)
        .task {
            await model.fetch()
        }
    }
}

// MARK: - UI

extension CollectionsScene {
    private var collectionsView: some View {
        ForEach(model.createGridItems(from: nftDataList)) { gridItem in
            NavigationLink(value: gridItem.destination) {
                GridPosterView(
                    assetImage: gridItem.assetImage,
                    title: gridItem.title
                )
            }
        }
    }
}
