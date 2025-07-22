// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Primitives
import Store
import PerpetualService

@Observable
@MainActor
public final class PerpetualsSceneViewModel {
    
    private let perpetualService: PerpetualServiceable
    
    public let wallet: Wallet
    
    // Requests
    public var positionsRequest: PerpetualPositionsRequest
    public var perpetualsRequest: PerpetualsRequest
    
    // Observed values
    public var positions: [PerpetualPositionData] = []
    public var perpetuals: [Perpetual] = []
    
    public var isLoading: Bool = false
    
    public init(
        wallet: Wallet,
        perpetualService: PerpetualServiceable
    ) {
        self.wallet = wallet
        self.perpetualService = perpetualService
        self.positionsRequest = PerpetualPositionsRequest(walletId: wallet.id)
        self.perpetualsRequest = PerpetualsRequest()
    }
}

// MARK: - Actions

extension PerpetualsSceneViewModel {
    public func fetch() {
        Task {
            await updateMarkets()
            await updatePositions()
        }
    }
    
    public func updatePositions() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await perpetualService.updatePositions(wallet: wallet)
        } catch {
            print("PerpetualsSceneViewModel: Failed to update positions: \(error)")
        }
    }
    
    public func updateMarkets() async {
        do {
            try await perpetualService.updateMarkets()
        } catch {
            print("PerpetualsSceneViewModel: Failed to update markets: \(error)")
        }
    }
    
    public var positionViewModels: [PerpetualPositionItemViewModel] {
        positions.map {
            PerpetualPositionItemViewModel(
                position: $0.position,
                perpetual: $0.perpetual
            )
        }
    }
}
