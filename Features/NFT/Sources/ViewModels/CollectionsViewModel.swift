// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Components
import NFTService
import Primitives
import Store
import Localization
import Style
import SwiftUI
import PrimitivesComponents
import WalletService

@Observable
@MainActor
public final class CollectionsViewModel: CollectionsViewable, Sendable {
    private let walletService: WalletService
    private let nftService: NFTService

    public var request: NFTRequest
    public var nftDataList: [NFTData] = []

    public var isPresentingReceiveSelectAssetType: SelectAssetType?

    public var wallet: Wallet

    public init(
        nftService: NFTService,
        walletService: WalletService,
        wallet: Wallet
    ) {
        self.nftService = nftService
        self.walletService = walletService
        self.wallet = wallet
        self.request = NFTRequest(walletId: wallet.id, filter: .all)
    }

    public var title: String { Localized.Nft.collections }

    public var currentWallet: Wallet? {
        walletService.currentWallet
    }

    public var content: GridContent {
        let items = nftDataList
            .filter { $0.collection.isVerified }
            .map { buildGridItem(from: $0) }

        let unverifiedCount = nftDataList
            .filter { $0.collection.isVerified == false }
            .count

        return GridContent(items: items, unverifiedCount: unverifiedCount > 0 ? String(unverifiedCount) : nil)
    }

    // MARK: - Actions

    public func fetch() async {
        do {
            let count = try await nftService.updateAssets(wallet: wallet)
            debugLog("update nfts: \(count)")
        } catch {
            debugLog("update nfts error: \(error)")
        }
    }
}
