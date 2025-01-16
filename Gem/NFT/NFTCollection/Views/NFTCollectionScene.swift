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

struct NFTCollectionScene: View {
    private var gridItems: [GridItem] {
        [
            GridItem(spacing: 16),
            GridItem(spacing: 16)
        ]
    }
    
    private var model: NFTCollectionViewModel
    
    @Query<NFTRequest>
    private var nftDataList: [NFTData]
    
    init(model: NFTCollectionViewModel) {
        _nftDataList = Query(model.nftRequest)
        self.model = model
    }

    var body: some View {
        ScrollView {
            LazyVGrid(columns: gridItems) {
                switch model.sceneStep {
                case .collections:
                    nftCollectionView
                case .nft(let collectionId):
                    buildNFTAssetView(collectionId: collectionId)
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
        .padding(.horizontal, 16)
        .background(Colors.grayBackground)
        .navigationBarTitleDisplayMode(.large)
        .navigationTitle(model.title(list: nftDataList))
        .taskOnce(onTaskOnce)
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
    private func buildNFTAssetView(collectionId: String) -> some View {
        if let nftData = nftDataList.first(where: { $0.collection.id == collectionId }) {
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
        } else {
            EmptyView()
        }
    }
    
    private func onTaskOnce() {
        Task {
            await model.taskOnce()
        }
    }
}
