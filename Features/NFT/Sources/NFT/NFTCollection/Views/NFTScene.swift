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
        _nftDataList = Query(model.nftRequest)
        self.model = model
    }

    public var body: some View {
        ScrollView {
            LazyVGrid(columns: gridItems) {
                switch model.sceneStep {
                case .collections:
                    nftCollectionView
                case .nft(let collectionId):
                    if let nftData = nftDataList.first(where: { $0.collection.id == collectionId }) {
                        buildNFTAssetView(nftData: nftData)
                    }
                }
            }
        }
        .refreshable {
            Task {
                await model.updateNFT()
            }
        }
        .overlay(content: {
            if nftDataList.isEmpty {
                LoadingView(size: .large, tint: Colors.gray)
            }
        })
        .padding(.horizontal, Spacing.medium)
        .background(Colors.grayBackground)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(model.title(list: nftDataList))
        .taskOnce(fetch)
    }
    
    private var nftCollectionView: some View {
        ForEach(nftDataList, id: \.collection.id) { item in
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
            await model.taskOnce()
        }
    }
}
