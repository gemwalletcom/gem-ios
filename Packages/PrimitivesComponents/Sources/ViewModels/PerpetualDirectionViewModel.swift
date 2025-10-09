// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Localization

public struct PerpetualDirectionViewModel {
    
    let direction: PerpetualDirection
    
    public init(direction: PerpetualDirection) {
        self.direction = direction
    }
    
    var title: String {
        switch direction {
        case .short: Localized.Perpetual.short
        case .long: Localized.Perpetual.long
        }
    }
}
