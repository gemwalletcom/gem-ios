// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Localization

public struct PriceAlertsViewModel {
    
    public let priceAlerts: [PriceAlert]
    
    public init(priceAlerts: [PriceAlert]) {
        self.priceAlerts = priceAlerts.filter { $0.shouldDisplay }
    }
    
    public var hasPriceAlerts: Bool { priceAlerts.isNotEmpty }
    public var setPriceAlertTitle: String { Localized.PriceAlerts.SetAlert.title }
    public var priceAlertsTitle: String { Localized.Settings.PriceAlerts.title }
    public var priceAlertCount: String { "\(priceAlerts.count)" }
}
