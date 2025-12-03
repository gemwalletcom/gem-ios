// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Components
import Primitives
import Store
import SwiftUI
import PrimitivesComponents

@Observable
@MainActor
public final class CollectionViewModel: CollectionsViewable, Sendable {
    private let collectionName: String

    public var request: NFTRequest
    public var nftDataList: [NFTData] = []

    public var isPresentingReceiveSelectAssetType: SelectAssetType?

    public var wallet: Wallet

    public init(
        wallet: Wallet,
        collectionId: String,
        collectionName: String
    ) {
        self.wallet = wallet
        self.collectionName = collectionName
        self.request = NFTRequest(walletId: wallet.id, filter: .collection(id: collectionId))
    }

    public var title: String { collectionName }

    public var items: [GridPosterViewItem] {
        nftDataList.flatMap { data in
            data.assets.map { buildGridItem(collection: data.collection, asset: $0) }
        }
    }

}
