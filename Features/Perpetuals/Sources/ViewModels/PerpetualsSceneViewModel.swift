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
    
    public let wallet: Wallet
    public let positions: [PerpetualPositionData]
    public let perpetuals: [PerpetualData]
    public let walletBalance: WalletBalance
    
    public var isLoading: Bool = false
    public let preferences: Preferences = .standard
    
    private let onSelectAssetType: ((SelectAssetType) -> Void)?
    
    
    public init(
        wallet: Wallet,
        perpetualService: PerpetualServiceable,
        positions: [PerpetualPositionData],
        perpetuals: [PerpetualData],
        walletBalance: WalletBalance,
        onSelectAssetType: ((SelectAssetType) -> Void)? = nil
    ) {
        self.wallet = wallet
        self.perpetualService = perpetualService
        self.positions = positions
        self.perpetuals = perpetuals
        self.walletBalance = walletBalance
        self.onSelectAssetType = onSelectAssetType
    }
    
    public var navigationTitle: String { "Perpetuals" }
    public var positionsSectionTitle: String { Localized.Perpetual.positions }
    public var marketsSectionTitle: String { "Markets" }
    public var pinnedSectionTitle: String { Localized.Common.pinned }
    public var noMarketsText: String { "No markets" }
    public var pinImage: Image { Images.System.pin }
    
    public var sections: PerpetualsSections {
        PerpetualsSections.from(perpetuals)
    }
    
    public var headerViewModel: PerpetualsHeaderViewModel {
        PerpetualsHeaderViewModel(
            walletType: wallet.type,
            balance: walletBalance
        )
    }
}

// MARK: - Actions

extension PerpetualsSceneViewModel {
    public func fetch() async {
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
    
    public func onHeaderAction(type: HeaderButtonType) {
        switch type {
        case .deposit:
            onSelectAssetType?(.deposit)
        case .withdraw:
            onSelectAssetType?(.withdraw)
        default:
            break
        }
    }
    
    public func onPinPerpetual(_ perpetualId: String, value: Bool) {
        do {
            try perpetualService.setPinned(value, perpetualId: perpetualId)
        } catch {
            NSLog("PerpetualsSceneViewModel pin perpetual error: \(error)")
        }
    }
}
