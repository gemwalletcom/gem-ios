// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

extension PriceAlertData: Identifiable {
    public var id: String { asset.id.identifier + priceAlert.id }
}
