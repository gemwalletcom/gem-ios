// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Components
import Primitives
import Store
import Localization
import SwiftUI
import PrimitivesComponents

@Observable
@MainActor
public final class UnverifiedCollectionsViewModel: CollectionsViewable, Sendable {
    public let query: ObservableQuery<NFTRequest>
    public var nftDataList: [NFTData] { query.value }

    public var isPresentingReceiveSelectAssetType: SelectAssetType?

    public var wallet: Wallet

    public init(wallet: Wallet) {
        self.wallet = wallet
        self.query = ObservableQuery(NFTRequest(walletId: wallet.walletId, filter: .unverified), initialValue: [])
    }

    public var title: String { Localized.Asset.Verification.unverified }

    public var content: CollectionsContent {
        CollectionsContent(items: nftDataList.map { buildGridItem(from: $0) })
    }
}
