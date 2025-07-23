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
    private let initialPerpetual: Perpetual
    
    public let wallet: Wallet
    public var perpetualsRequest: PerpetualsRequest
    public var perpetuals: [Perpetual] = []
    public var positionsRequest: PerpetualPositionsRequest
    public var positions: [PerpetualPositionData] = []
    public var state: StateViewType<[ChartCandleStick]> = .loading
    public var currentPeriod: ChartPeriod = .day {
        didSet {
            Task {
                await loadCandlesticks()
            }
        }
    }
    
    public var perpetual: Perpetual {
        perpetuals.first(where: { $0.id == initialPerpetual.id }) ?? initialPerpetual
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
        self.initialPerpetual = perpetual
        self.perpetualService = perpetualService
        self.perpetualsRequest = PerpetualsRequest()
        self.positionsRequest = PerpetualPositionsRequest(walletId: wallet.id, perpetualId: perpetual.id)
    }
    
    public var navigationTitle: String {
        perpetualViewModel.name
    }
    
    
    public func loadData() async {
        do {
            try await perpetualService.updateMarkets()
            try await perpetualService.updatePositions(wallet: wallet)
            await fetchCandlesticks()
        } catch {
            print("Failed to load data: \(error)")
        }
    }
    
    public func fetchCandlesticks() async {
        state = .loading
        
        let coin = perpetual.name
        let endTime = Int(Date().timeIntervalSince1970 * 1000)
        let interval = intervalForPeriod(currentPeriod)
        let intervalMs = intervalDuration(for: interval) * 1000
        // Calculate start time for 60 candles
        let startTime = endTime - (60 * intervalMs)
        
        do {
            let allCandlesticks = try await perpetualService.getCandlesticks(
                coin: coin,
                startTime: startTime,
                endTime: endTime,
                interval: interval
            )
            
            // Take only the last 60 elements
            let candlesticks = Array(allCandlesticks.suffix(60))
            
            if candlesticks.isEmpty {
                state = .noData
            } else {
                state = .data(candlesticks)
            }
        } catch {
            state = .error(error)
        }
    }
    
    private func loadCandlesticks() async {
        await fetchCandlesticks()
    }
    
    private func periodDuration(for period: ChartPeriod) -> Int {
        switch period {
        case .hour:
            return 60 * 60 // 1 hour
        case .day:
            return 24 * 60 * 60 // 24 hours
        case .week:
            return 7 * 24 * 60 * 60 // 7 days
        case .month:
            return 30 * 24 * 60 * 60 // 30 days
        case .year:
            return 365 * 24 * 60 * 60 // 365 days
        case .all:
            return 365 * 5 * 24 * 60 * 60 // 5 years
        }
    }
    
    private func intervalForPeriod(_ period: ChartPeriod) -> String {
        switch period {
        case .hour:
            return "1m"  // 60 x 1min = 1 hour
        case .day:
            return "5m"  // 60 x 5min = 5 hours (covers recent trading)
        case .week:
            return "1h"  // 60 x 1hr = 2.5 days
        case .month:
            return "4h"  // 60 x 4hr = 10 days
        case .year:
            return "1d"  // 60 x 1day = 60 days
        case .all:
            return "1w"  // 60 x 1week = ~1.15 years
        }
    }
    
    private func intervalDuration(for interval: String) -> Int {
        switch interval {
        case "1m":
            return 60 // 1 minute in seconds
        case "5m":
            return 5 * 60 // 5 minutes in seconds
        case "1h":
            return 60 * 60 // 1 hour in seconds
        case "4h":
            return 4 * 60 * 60 // 4 hours in seconds
        case "1d":
            return 24 * 60 * 60 // 1 day in seconds
        case "1w":
            return 7 * 24 * 60 * 60 // 1 week in seconds
        default:
            return 60 // default to 1 minute
        }
    }
}
