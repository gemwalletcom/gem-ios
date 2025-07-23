// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Primitives
import Store
import PerpetualService
import Preferences
import PrimitivesComponents

@Observable
@MainActor
public final class PerpetualsSceneViewModel {
    
    private let perpetualService: PerpetualServiceable
    
    public let wallet: Wallet
    public let positions: [PerpetualPositionData]
    public let perpetuals: [Perpetual]
    
    public var isLoading: Bool = false
    public let preferences: Preferences = .standard
    
    public init(
        wallet: Wallet,
        perpetualService: PerpetualServiceable,
        positions: [PerpetualPositionData],
        perpetuals: [Perpetual]
    ) {
        self.wallet = wallet
        self.perpetualService = perpetualService
        self.positions = positions
        self.perpetuals = perpetuals
    }
    
    public var positionViewModels: [PerpetualPositionItemViewModel] {
        positions.flatMap { positionData in
            let perpetualViewModel = PerpetualViewModel(perpetual: positionData.perpetual, currencyStyle: .currency)
            return positionData.positions.map { position in
                PerpetualPositionItemViewModel(
                    position: position,
                    perpetualViewModel: perpetualViewModel
                )
            }
        }
    }
    
    public var headerViewModel: PerpetualsHeaderViewModel {
        PerpetualsHeaderViewModel(
            walletType: wallet.type,
            totalValue: 10,
            currencyCode: "USD"
        )
    }
}

// MARK: - Actions

extension PerpetualsSceneViewModel {
    public func fetch() async {
        await updatePositions()
        await updateMarkets()
    }
    
    private func updatePositions() async {
        do {
            try await perpetualService.updatePositions(wallet: wallet)
        } catch {
            NSLog("Failed to update positions: \(error)")
        }
    }
    
    private func updateMarkets() async {
        do {
            try await perpetualService.updateMarkets()
        } catch {
            NSLog("Failed to update markets: \(error)")
        }
    }
}
