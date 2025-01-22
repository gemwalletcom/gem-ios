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
        _nftDataList = Query(constant: model.nftRequest)
        self.model = model
    }
    
    public var body: some View {
        ScrollView {
            LazyVGrid(columns: gridItems) {
                switch model.sceneStep {
                case .collections:
                    nftCollectionView
                case .collection(let collection):
                    if let nftData = nftDataList.first(where: { $0.collection.id == collection.id }) {
                        buildNFTAssetView(nftData: nftData)
                    }
                }
            }
        }
        .refreshable(action: fetch)
        .overlay {
            // TODO: - migrate to StateEmptyView + Overlay, when we will have image
            if nftDataList.isEmpty {
                Text(Localized.Activity.EmptyState.message)
                    .textStyle(.body)
            }
        }
        .padding(.horizontal, Spacing.medium)
        .background(Colors.grayBackground)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(model.title)
        .taskOnce(fetch)
    }
    
    private var nftCollectionView: some View {
        ForEach(nftDataList) { item in
            let gridItem = model.createGridItem(from: item)
            
            NavigationLink(value: gridItem.destination) {
                GridPosterView(
                    assetImage: gridItem.assetImage,
                    title: gridItem.title
                )
            }
        }
    }
    
    @ViewBuilder
    private func buildNFTAssetView(nftData: NFTData) -> some View {
        ForEach(nftData.assets) { asset in
            NavigationLink(value: Scenes.NFTDetails(collection: nftData.collection, asset: asset)) {
                GridPosterView(
                    assetImage: AssetImage(
                        imageURL: URL(string: asset.image.imageUrl),
                        placeholder: nil,
                        chainPlaceholder: nil
                    ),
                    title: asset.name
                )
            }
        }
    }
    
    private func fetch() {
        Task {
            await model.fetch()
        }
    }
}
