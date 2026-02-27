// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Primitives
import Store
import Preferences
import Localization
import BalanceService
import PrimitivesComponents
import Components
import Style

@Observable
@MainActor
public final class AssetsResultsSceneViewModel {
    public static let defaultLimit = 100

    private let assetsEnabler: any AssetsEnabler
    private let balanceService: BalanceService
    private let preferences: Preferences
    private let wallet: Wallet

    let onSelectAssetAction: AssetAction

    public let searchQuery: ObservableQuery<WalletSearchRequest>
    var searchResult: WalletSearchResult { searchQuery.value }
    var isPresentingToastMessage: ToastMessage?

    public init(
        wallet: Wallet,
        assetsEnabler: any AssetsEnabler,
        balanceService: BalanceService,
        preferences: Preferences,
        request: WalletSearchRequest,
        onSelectAsset: @escaping (Asset) -> Void
    ) {
        self.wallet = wallet
        self.assetsEnabler = assetsEnabler
        self.balanceService = balanceService
        self.preferences = preferences
        self.searchQuery = ObservableQuery(request, initialValue: .empty)
        self.onSelectAssetAction = onSelectAsset
    }

    var title: String { Localized.Assets.title }
    var currencyCode: String { preferences.currency }
    var sections: WalletSearchSections { .from(searchResult) }
    var showPinned: Bool { sections.pinnedAssets.isNotEmpty }
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
            do {
                try await assetsEnabler.enableAssets(wallet: wallet, assetIds: [asset.id], enabled: true)
                isPresentingToastMessage = .addedToWallet()
            } catch {
                debugLog("AssetsResultsSceneViewModel add to wallet error: \(error)")
            }
        }
    }

    private func onPinAsset(_ assetData: AssetData, value: Bool) {
        do {
            try balanceService.setPinned(value, walletId: wallet.walletId, assetId: assetData.asset.id)
            isPresentingToastMessage = .pin(assetData.asset.name, pinned: value)
        } catch {
            debugLog("AssetsResultsSceneViewModel pin asset error: \(error)")
        }
    }
}
