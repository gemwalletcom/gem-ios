// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

extension PriceData: Identifiable {
    public var id: String { asset.id.identifier }
}
