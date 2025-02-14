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

public struct NFTScene: View {
    
    private var gridItems: [GridItem] {
        [
            GridItem(spacing: Spacing.medium),
            GridItem(spacing: Spacing.medium)
        ]
    }
    
    private var model: NFTCollectionViewModel
    
    @Query<NFTRequest>
    private var nftDataList: [NFTData]
    
    public init(model: NFTCollectionViewModel) {
        self.model = model
        _nftDataList = Query(constant: model.nftRequest)
    }
    
    public var body: some View {
        ScrollView {
            LazyVGrid(columns: gridItems) {
                nftCollectionView
            }
        }
        .refreshable(action: model.fetch)
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
        .taskOnce(fetch)
    }
    
    private var nftCollectionView: some View {
        ForEach(model.createGridItems(from: nftDataList)) { gridItem in
            let view = GridPosterView(
                assetImage: gridItem.assetImage,
                title: gridItem.title
            )
            if let destination = gridItem.destination {
                NavigationLink(value: destination) {
                    view
                }
            } else {
                NavigationCustomLink(with: view) {
                    model.onSelect?(gridItem.asset)
                }
            }
        }
    }
    
    private func fetch() {
        Task {
            await model.fetch()
        }
    }
}
