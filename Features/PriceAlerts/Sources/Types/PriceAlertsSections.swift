// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

struct PriceAlertsSections {
    let autoAlerts: [PriceAlertData]
    let manualAlerts: [Asset: [PriceAlertData]]
}
