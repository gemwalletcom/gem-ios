// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import Style

extension PerpetualDirection {
    var color: Color {
        switch self {
        case .short: Colors.red
        case .long: Colors.green
        }
    }
}
