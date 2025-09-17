// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public enum ButtonType: Hashable, Sendable {
    case primary(_ buttonState: ButtonState = .normal)

    var state: ButtonState {
        switch self {
        case .primary(let state): state
        }
    }
    
    public var isDisabled: Bool {
        switch self {
        case .primary(let state): state != .normal
        }
    }
}
