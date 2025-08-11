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
    private let onTransferComplete: ((TransferData) -> Void)?
    
    public init(
        wallet: Wallet,
        perpetualService: PerpetualServiceable,
        positions: [PerpetualPositionData],
        perpetuals: [PerpetualData],
        walletBalance: WalletBalance,
        onSelectAssetType: ((SelectAssetType) -> Void)? = nil,
        onTransferComplete: ((TransferData) -> Void)? = nil
    ) {
        self.wallet = wallet
        self.perpetualService = perpetualService
        self.positions = positions
        self.perpetuals = perpetuals
        self.walletBalance = walletBalance
        self.onSelectAssetType = onSelectAssetType
        self.onTransferComplete = onTransferComplete
    }
    
    public var navigationTitle: String { "Perpetuals" }
    public var positionsSectionTitle: String { Localized.Perpetual.positions }
    public var marketsSectionTitle: String { "Markets" }
    public var noMarketsText: String { "No markets" }
    
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
        guard preferences.perpetualMarketsUpdatedAt.isOutdated(byDays: 7) else { return }
        
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
}
