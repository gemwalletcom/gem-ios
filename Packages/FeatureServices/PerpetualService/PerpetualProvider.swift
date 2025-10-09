// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Blockchain

public protocol PerpetualProvidable: Sendable {
    func provider() -> Primitives.PerpetualProvider
    func getPositions(address: String) async throws -> PerpetualPositionsSummary
    func getPerpetualsData() async throws -> [PerpetualData]
    func getCandlesticks(symbol: String, period: ChartPeriod) async throws -> [ChartCandleStick]
}

struct GatewayPerpetualProvider: PerpetualProvidable {
    
    let gateway: GatewayService
    let chain: Primitives.Chain
    
    init(gateway: GatewayService, chain: Primitives.Chain = .hyperCore) {
        self.gateway = gateway
        self.chain = chain
    }
    
    func provider() -> Primitives.PerpetualProvider {
        switch chain {
        case .hyperCore: return .hypercore
        default: return .hypercore
        }
    }
    
    func getPositions(address: String) async throws -> PerpetualPositionsSummary {
        try await gateway.getPositions(chain: chain, address: address)
    }
    
    func getPerpetualsData() async throws -> [PerpetualData] {
        try await gateway.getPerpetualsData(chain: chain)
    }
    
    func getCandlesticks(symbol: String, period: ChartPeriod) async throws -> [ChartCandleStick] {
        try await gateway.getCandlesticks(chain: chain, symbol: symbol, period: period)
    }
}
