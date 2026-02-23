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
final class PerpetualsSceneViewModel {
    private let observerService: any PerpetualObservable<HyperliquidSubscription>
    let perpetualService: PerpetualServiceable
    let activityService: ActivityService

    let preferences: Preferences = .standard
    let wallet: Wallet

    let positionsQuery: ObservableQuery<PerpetualPositionsRequest>
    let perpetualsQuery: ObservableQuery<PerpetualsRequest>
    let walletBalanceQuery: ObservableQuery<PerpetualWalletBalanceRequest>
    let recentsQuery: ObservableQuery<RecentActivityRequest>

    var recents: [RecentAsset] { recentsQuery.value }
    var positions: [PerpetualPositionData] { positionsQuery.value }
    var perpetuals: [PerpetualData] { perpetualsQuery.value }
    var walletBalance: WalletBalance { walletBalanceQuery.value }

    var isSearchPresented: Bool = false
    var searchQuery: String = .empty
    var isSearching: Bool = false
    var isPresentingRecents: Bool = false
    var isPresentingPortfolio: Bool = false

    let onSelectAssetType: ((SelectAssetType) -> Void)?
    let onSelectAsset: ((Asset) -> Void)?

    init(
        wallet: Wallet,
        perpetualService: PerpetualServiceable,
        observerService: any PerpetualObservable<HyperliquidSubscription>,
        activityService: ActivityService,
        onSelectAssetType: ((SelectAssetType) -> Void)? = nil,
        onSelectAsset: ((Asset) -> Void)? = nil
    ) {
        self.wallet = wallet
        self.perpetualService = perpetualService
        self.observerService = observerService
        self.activityService = activityService
        self.onSelectAssetType = onSelectAssetType
        self.onSelectAsset = onSelectAsset
        self.positionsQuery = ObservableQuery(PerpetualPositionsRequest(walletId: wallet.walletId, searchQuery: ""), initialValue: [])
        self.perpetualsQuery = ObservableQuery(PerpetualsRequest(searchQuery: ""), initialValue: [])
        self.walletBalanceQuery = ObservableQuery(PerpetualWalletBalanceRequest(walletId: wallet.walletId), initialValue: .zero)
        self.recentsQuery = ObservableQuery(RecentActivityRequest(walletId: wallet.walletId, limit: 10, types: [.perpetual]), initialValue: [])
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
    var showPinned: Bool { sections.pinned.isNotEmpty }
    var showMarkets: Bool { !isSearching || sections.markets.isNotEmpty || positions.isEmpty }
    var showRecents: Bool { isSearching && recents.isNotEmpty }

    var sections: PerpetualsSections { .from(perpetuals) }
    var recentModels: [AssetViewModel] { recents.map { AssetViewModel(asset: $0.asset) } }

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
    }

    func onAppear() async {
        do {
            try await observerService.subscribe(.allMids)
        } catch {
            debugLog("AllMids subscribe failed: \(error)")
        }
    }

    func onDisappear() async {
        do {
            try await observerService.unsubscribe(.allMids)
        } catch {
            debugLog("AllMids unsubscribe failed: \(error)")
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
        perpetualsQuery.request = PerpetualsRequest(searchQuery: trimmed)
        positionsQuery.request = PerpetualPositionsRequest(walletId: wallet.walletId, searchQuery: trimmed)
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
        do {
            try activityService.updateRecent(
                data: RecentActivityData(type: .perpetual, assetId: asset.id, toAssetId: nil),
                walletId: wallet.walletId
            )
        } catch {
            debugLog("Failed to update recent activity: \(error)")
        }
    }

    func onSelectRecents() {
        isPresentingRecents = true
    }

    func onSelectRecent(asset: Asset) {
        onSelectAsset?(asset)
        isPresentingRecents = false
    }

    func onSelectBalance() {
        isPresentingPortfolio = true
    }
}
