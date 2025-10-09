// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GemAPI
import Primitives
import Store

public struct ChartService: Sendable {
    private let chartProvider: any GemAPIChartService

    public init(chartProvider: any GemAPIChartService = GemAPIService.shared) {
        self.chartProvider = chartProvider
    }
    
    public func getCharts(assetId: AssetId, period: ChartPeriod) async throws -> Primitives.Charts {
        try await chartProvider
            .getCharts(assetId: assetId, period: period.rawValue)
    }
}
