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
    public var request: NFTRequest
    public var nftDataList: [NFTData] = []

    public var isPresentingReceiveSelectAssetType: SelectAssetType?

    public var wallet: Wallet

    public init(wallet: Wallet) {
        self.wallet = wallet
        self.request = NFTRequest(walletId: wallet.id, filter: .unverified)
    }

    public var title: String { Localized.Asset.Verification.unverified }

    public var content: GridContent {
        GridContent(items: nftDataList.map { buildGridItem(from: $0) })
    }
}
