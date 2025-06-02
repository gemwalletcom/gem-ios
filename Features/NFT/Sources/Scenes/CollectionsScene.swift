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

public struct CollectionsScene: View {
    private let model: CollectionsViewModel
    
    public init(model: CollectionsViewModel) {
        self.model = model
    }
    
    public var body: some View {
        ScrollView {
            LazyVGrid(columns: model.columns) {
                collectionsView
            }
        }
        .overlay {
            if model.nftDataList.isEmpty {
                EmptyContentView(model: model.emptyContentModel)
            }
        }
        .padding(.horizontal, .medium)
        .if(model.nftDataList.isNotEmpty) {
            $0.background(Colors.insetGroupedListStyle)
        }
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
        ForEach(model.createGridItems()) { gridItem in
            NavigationLink(value: gridItem.destination) {
                GridPosterView(
                    assetImage: gridItem.assetImage,
                    title: gridItem.title
                )
            }
        }
    }
}
