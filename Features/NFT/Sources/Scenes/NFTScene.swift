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
    
    private let model: NFTCollectionViewModel

    @Query<NFTRequest>
    private var nftDataList: [NFTData]
    
    public init(model: NFTCollectionViewModel) {
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
            LazyVGrid(columns: gridItems) {
                nftCollectionView
            }
        }
        .overlay {
            if nftDataList.isEmpty {
                EmptyContentView(model: model.emptyContentModel)
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
    
    private var nftCollectionView: some View {
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
