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
import PrimitivesComponents

public struct NFTScene: View {
    
    private var gridItems: [GridItem] {
        [
            GridItem(spacing: Spacing.medium),
            GridItem(spacing: Spacing.medium)
        ]
    }
    
    @Binding var isPresentingSelectAssetType: SelectAssetType?
    
    private var model: NFTCollectionViewModel
    
    @Query<NFTRequest>
    private var nftDataList: [NFTData]
    
    public init(
        model: NFTCollectionViewModel,
        isPresentingSelectAssetType: Binding<SelectAssetType?>
    ) {
        self.model = model
        _isPresentingSelectAssetType = isPresentingSelectAssetType
        _nftDataList = Query(constant: model.nftRequest)
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
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    isPresentingSelectAssetType = .receive(.collection)
                } label: {
                    Images.System.plus
                }
            }
        }
        .refreshable(action: fetch)
        .overlay {
            if nftDataList.isEmpty {
                EmptyContentView(model: model.emptyContentModel)
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
            NavigationLink(
                value: Scenes.NFTDetails(assetData: NFTAssetData(collection: nftData.collection, asset: asset))
            ) {
                GridPosterView(
                    assetImage: AssetImage(
                        type: nftData.collection.name,
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
