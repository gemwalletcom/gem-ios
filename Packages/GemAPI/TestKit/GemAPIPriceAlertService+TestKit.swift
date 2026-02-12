// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GemAPI
import Primitives

public final class GemAPIPriceAlertServiceMock: GemAPIPriceAlertService, @unchecked Sendable {
    private let priceAlerts: [PriceAlert]

    public init(priceAlerts: [PriceAlert] = []) {
        self.priceAlerts = priceAlerts
    }

    public func getPriceAlerts(assetId: String?) async throws -> [PriceAlert] { priceAlerts }
    public func addPriceAlerts(priceAlerts: [PriceAlert]) async throws {}
    public func deletePriceAlerts(priceAlerts: [PriceAlert]) async throws {}
}
