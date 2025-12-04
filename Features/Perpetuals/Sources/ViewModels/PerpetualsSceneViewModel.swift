// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Primitives
import Store
import PerpetualService
import Preferences
import PrimitivesComponents
import Components
import Localization
import Style
import ActivityService

@Observable
@MainActor
public final class PerpetualsSceneViewModel {
    private let perpetualService: PerpetualServiceable
    private let activityService: ActivityService

    let preferences: Preferences = .standard
    let wallet: Wallet

    var positionsRequest: PerpetualPositionsRequest
    var perpetualsRequest: PerpetualsRequest
    var walletBalanceRequest: PerpetualWalletBalanceRequest
    var recentActivityRequest: RecentActivityRequest

    var recentActivities: [Asset] = []
    var positions: [PerpetualPositionData] = []
    var perpetuals: [PerpetualData] = []
    var walletBalance: WalletBalance = .zero

    var isSearchPresented: Bool = false
    var searchQuery: String = .empty
    var isSearching: Bool = false

    let onSelectAssetType: ((SelectAssetType) -> Void)?
    let onSelectAsset: ((Asset) -> Void)?

    public init(
        wallet: Wallet,
        perpetualService: PerpetualServiceable,
        activityService: ActivityService,
        onSelectAssetType: ((SelectAssetType) -> Void)? = nil,
        onSelectAsset: ((Asset) -> Void)? = nil
    ) {
        self.wallet = wallet
        self.perpetualService = perpetualService
        self.activityService = activityService
        self.onSelectAssetType = onSelectAssetType
        self.onSelectAsset = onSelectAsset
        self.positionsRequest = PerpetualPositionsRequest(walletId: wallet.id, searchQuery: "")
        self.perpetualsRequest = PerpetualsRequest(searchQuery: "")
        self.walletBalanceRequest = PerpetualWalletBalanceRequest(walletId: wallet.id)
        self.recentActivityRequest = RecentActivityRequest(
            walletId: wallet.id,
            limit: 10,
            types: [.perpetual]
        )
    }

    var navigationTitle: String { Localized.Perpetuals.title }
    var positionsSectionTitle: String { Localized.Perpetual.positions }
    var marketsSectionTitle: String { Localized.Perpetuals.markets }
    var pinnedSectionTitle: String { Localized.Common.pinned }
    var noMarketsText: String? {
        !isSearching ? Localized.Perpetuals.EmptyState.noMarkets : Localized.Perpetuals.EmptyState.noMarketsFound
    }
    var pinImage: Image { Images.System.pin }
    var searchImage: Image { Images.System.search }

    var showPositions: Bool { positions.isNotEmpty }
    var showPinned: Bool { !isSearching && sections.pinned.isNotEmpty }
    var showMarkets: Bool { !isSearching || sections.markets.isNotEmpty || positions.isEmpty }

    var showRecent: Bool { isSearching && recentActivities.isNotEmpty }

    var sections: PerpetualsSections {
        let source: [PerpetualData]
        if isSearching {
            let positionIds = Set(positions.map { $0.perpetual.id })
            source = perpetuals.filter { !positionIds.contains($0.perpetual.id) }
        } else {
            source = perpetuals
        }
        return PerpetualsSections.from(source)
    }

    var activityModels: [AssetViewModel] {
        recentActivities.map { AssetViewModel(asset: $0) }
    }

    var headerViewModel: PerpetualsHeaderViewModel {
        PerpetualsHeaderViewModel(
            walletType: wallet.type,
            balance: walletBalance
        )
    }
}

// MARK: - Businesss Logic

extension PerpetualsSceneViewModel {
    func fetch() async {
        await updateMarkets()
        await updatePositions()
    }

    private func updatePositions() async {
        do {
            try await perpetualService.updatePositions(wallet: wallet)
        } catch {
            debugLog("Failed to update positions: \(error)")
        }
    }

    func updateMarkets() async {
        guard preferences.perpetualMarketsUpdatedAt.isOutdated(byMinutes: 1) else { return }

        do {
            try await perpetualService.updateMarkets()
            preferences.perpetualMarketsUpdatedAt = .now
        } catch {
            debugLog("Failed to update markets: \(error)")
        }
    }

    func onSelectHeaderAction(type: HeaderButtonType) {
        switch type {
        case .deposit:
            onSelectAssetType?(.deposit)
        case .withdraw:
            onSelectAssetType?(.withdraw)
        default:
            break
        }
    }

    func onPinPerpetual(_ perpetualId: String, value: Bool) {
        do {
            try perpetualService.setPinned(value, perpetualId: perpetualId)
        } catch {
            debugLog("PerpetualsSceneViewModel pin perpetual error: \(error)")
        }
    }

    func onSearchQueryChange(_ _: String, _ newValue: String) {
        let trimmed = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
        perpetualsRequest = PerpetualsRequest(searchQuery: trimmed)
        positionsRequest = PerpetualPositionsRequest(walletId: wallet.id, searchQuery: trimmed)
    }

    func onSearchPresentedChange(_ _: Bool, _ isPresented: Bool) {
        if !isPresented {
            searchQuery = .empty
        }
    }

    func onSelectSearchButton() {
        isSearchPresented = true
    }

    func onSelectPerpetual(asset: Asset) {
        onSelectAsset?(asset)
        try? activityService.updateRecent(type: .perpetual, assetId: asset.id, walletId: wallet.walletId)
    }

    func onSelectRecentPerpetual(asset: Asset) {
        onSelectAsset?(asset)
    }
}
