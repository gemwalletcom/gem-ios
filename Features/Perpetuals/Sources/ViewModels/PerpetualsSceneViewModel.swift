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

@Observable
@MainActor
public final class PerpetualsSceneViewModel {
    private let perpetualService: PerpetualServiceable

    let preferences: Preferences = .standard
    let wallet: Wallet

    var positionsRequest: PerpetualPositionsRequest
    var perpetualsRequest: PerpetualsRequest
    var walletBalanceRequest: PerpetualWalletBalanceRequest

    var positions: [PerpetualPositionData] = []
    var perpetuals: [PerpetualData] = []
    var walletBalance: WalletBalance = .zero

    var isSearchPresented: Bool = false
    var searchQuery: String = .empty
    var isSearching: Bool = false

    let onSelectAssetType: ((SelectAssetType) -> Void)?

    public init(
        wallet: Wallet,
        perpetualService: PerpetualServiceable,
        onSelectAssetType: ((SelectAssetType) -> Void)? = nil
    ) {
        self.wallet = wallet
        self.perpetualService = perpetualService
        self.positionsRequest = PerpetualPositionsRequest(walletId: wallet.id)
        self.perpetualsRequest = PerpetualsRequest(searchQuery: "")
        self.walletBalanceRequest = PerpetualWalletBalanceRequest(walletId: wallet.id)
        self.onSelectAssetType = onSelectAssetType
    }

    var navigationTitle: String { "Perpetuals" }
    var positionsSectionTitle: String { Localized.Perpetual.positions }
    var marketsSectionTitle: String { "Markets" }
    var pinnedSectionTitle: String { Localized.Common.pinned }
    var noMarketsText: String? { !isSearching ? "No markets" : "No markets found" }
    var pinImage: Image { Images.System.pin }
    var searchImage: Image { Images.System.search }

    var showPositions: Bool { !isSearching && positions.isNotEmpty }
    var showPinned: Bool { !isSearching && sections.pinned.isNotEmpty }

    var sections: PerpetualsSections { PerpetualsSections.from(perpetuals) }

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
            NSLog("Failed to update positions: \(error)")
        }
    }
    
    func updateMarkets() async {
        guard preferences.perpetualMarketsUpdatedAt.isOutdated(byMinutes: 1) else { return }
        
        do {
            try await perpetualService.updateMarkets()
            preferences.perpetualMarketsUpdatedAt = .now
        } catch {
            NSLog("Failed to update markets: \(error)")
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
            NSLog("PerpetualsSceneViewModel pin perpetual error: \(error)")
        }
    }

    func onSearchQueryChange(_ _: String, _ newValue: String) {
        let trimmed = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
        perpetualsRequest = PerpetualsRequest(searchQuery: trimmed)
    }

    func onSearchPresentedChange(_ _: Bool, _ isPresented: Bool) {
        if !isPresented {
            searchQuery = .empty
        }
    }

    func onSelectSearchButton() {
        isSearchPresented = true
    }
}

// MARK: - Private

extension PerpetualsSceneViewModel {
    private func updatePositions() async {
        do {
            try await perpetualService.updatePositions(wallet: wallet)
        } catch {
            NSLog("Failed to update positions: \(error)")
        }
    }

    private func updateMarkets() async {
        guard preferences.perpetualMarketsUpdatedAt.isOutdated(byHours: 12) else { return }

        do {
            try await perpetualService.updateMarkets()
            preferences.perpetualMarketsUpdatedAt = .now
        } catch {
            NSLog("Failed to update markets: \(error)")
        }
    }
}
