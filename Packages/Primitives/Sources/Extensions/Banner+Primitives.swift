// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

extension Banner: Identifiable {
    public var id: String {
        [wallet?.id, asset?.id.identifier, event.rawValue].compactMap { $0 }.joined(separator: "_")
    }
}
