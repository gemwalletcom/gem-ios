// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Components
import NFTService
import Primitives
import Store
import Localization
import SwiftUI
import PrimitivesComponents
import WalletService
import Style

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

    public var items: [GridPosterViewItem] {
        verifiedItems + unverifiedItem
    }
    
    // MARK: - Private

    private var verifiedItems: [GridPosterViewItem] {
        nftDataList
            .filter { $0.collection.isVerified }
            .map { buildGridItem(from: $0) }
    }

    private var unverifiedItem: [GridPosterViewItem] {
        let ids = nftDataList
            .filter { $0.collection.isVerified == false }
            .map(\.collection.id)

        guard ids.isNotEmpty else { return [] }
        return [.unverified(collectionIds: ids)]
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

extension GridPosterViewItem {
    static func unverified(collectionIds: [String]) -> GridPosterViewItem {
        GridPosterViewItem(
            id: collectionIds.joined(separator: "-").hash.asString,
            destination: Scenes.UnverifiedCollections(),
            assetImage: .image(Images.TokenStatus.warning),
            title: Localized.Asset.Verification.unverified,
            count: collectionIds.count
        )
    }
}
