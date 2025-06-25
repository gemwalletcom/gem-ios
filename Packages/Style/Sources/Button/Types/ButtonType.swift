// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public enum ButtonType: Hashable, Sendable {
    case primary(_ buttonState: ButtonState = .normal)
    case secondary

    var state: ButtonState {
        switch self {
        case .primary(let state): state
        case .secondary: .normal
        }
    }
}
