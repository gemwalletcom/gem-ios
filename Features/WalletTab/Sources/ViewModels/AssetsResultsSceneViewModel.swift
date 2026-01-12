// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Primitives
import Store
import Preferences
import Localization
import WalletsService
import PrimitivesComponents
import Components
import Style

@Observable
@MainActor
public final class AssetsResultsSceneViewModel {
    private let walletsService: WalletsService
    private let preferences: Preferences
    private let wallet: Wallet
    
    let onSelectAssetAction: AssetAction

    var request: WalletSearchRequest
    var searchResult: WalletSearchResult = .empty
    var isPresentingToastMessage: ToastMessage?

    public init(
        wallet: Wallet,
        walletsService: WalletsService,
        preferences: Preferences,
        request: WalletSearchRequest,
        onSelectAsset: @escaping (Asset) -> Void
    ) {
        self.wallet = wallet
        self.walletsService = walletsService
        self.preferences = preferences
        self.request = request
        self.onSelectAssetAction = onSelectAsset
    }

    var title: String { Localized.Assets.title }
    var currencyCode: String { preferences.currency }
    var sections: WalletSearchSections { .from(searchResult) }
    var showPinned: Bool { sections.pinned.isNotEmpty }
    var showAssets: Bool { sections.assets.isNotEmpty }

    func contextMenuItems(for assetData: AssetData) -> [ContextMenuItemType] {
        AssetContextMenu.items(
            for: assetData,
            onCopy: { [weak self] in
                self?.isPresentingToastMessage = .copy(
                    CopyTypeViewModel(type: .address(assetData.asset, address: $0), copyValue: $0).message
                )
            },
            onPin: { [weak self] in
                self?.onPinAsset(assetData, value: !assetData.metadata.isPinned)
            },
            onAddToWallet: { [weak self] in
                self?.onAddToWallet(assetData.asset)
            }
        )
    }
}

// MARK: - Actions

extension AssetsResultsSceneViewModel {
    private func onAddToWallet(_ asset: Asset) {
        Task {
            await walletsService.enableAssets(walletId: wallet.walletId, assetIds: [asset.id], enabled: true)
            isPresentingToastMessage = .addedToWallet()
        }
    }

    private func onPinAsset(_ assetData: AssetData, value: Bool) {
        do {
            try walletsService.setPinned(value, walletId: wallet.walletId, assetId: assetData.asset.id)
            isPresentingToastMessage = .pin(assetData.asset.name, pinned: value)
        } catch {
            debugLog("AssetsResultsSceneViewModel pin asset error: \(error)")
        }
    }
}
