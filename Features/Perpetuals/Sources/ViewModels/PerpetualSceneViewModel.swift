// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Primitives
import Store
import PerpetualService
import PrimitivesComponents
import Formatters
import Components
import Localization

@Observable
@MainActor
public final class PerpetualSceneViewModel {
    
    private let perpetualService: PerpetualServiceable
    
    public let wallet: Wallet
    public var perpetual: Perpetual
    public var positionsRequest: PerpetualPositionsRequest
    public var positions: [PerpetualPositionData] = [] {
        didSet {
            if let perpetual = positions.first?.perpetual {
                self.perpetual = perpetual
            }
        }
    }
    public var state: StateViewType<[ChartCandleStick]> = .loading
    public var currentPeriod: ChartPeriod = .hour {
        didSet {
            Task {
                await fetchCandlesticks()
            }
        }
    }
    
    public var perpetualViewModel: PerpetualViewModel {
        PerpetualViewModel(perpetual: perpetual)
    }
    
    public var positionViewModels: [PerpetualPositionViewModel] {
        positions.flatMap { $0.positions }.map {
            PerpetualPositionViewModel(position: $0)
        }
    }
    
    public init(
        wallet: Wallet,
        perpetual: Perpetual,
        perpetualService: PerpetualServiceable
    ) {
        self.wallet = wallet
        self.perpetual = perpetual
        self.perpetualService = perpetualService
        self.positionsRequest = PerpetualPositionsRequest(walletId: wallet.id, perpetualId: perpetual.id)
    }
    
    public var navigationTitle: String {
        perpetualViewModel.name
    }
    
    
    public func fetch() async {
        do {
            try await perpetualService.updateMarket(symbol: perpetual.name)
            try await perpetualService.updatePositions(wallet: wallet)
            await fetchCandlesticks()
        } catch {
            print("Failed to load data: \(error)")
        }
    }
    
    public func fetchCandlesticks() async {
        state = .loading
        
        do {
            let candlesticks = try await perpetualService.candlesticks(
                symbol: perpetual.name,
                period: currentPeriod
            )
            state = .data(candlesticks)
        } catch {
            state = .error(error)
        }
    }
}
