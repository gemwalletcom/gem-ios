// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public enum ButtonState: Hashable {
    case normal
    case loading(showProgress: Bool = true)
    case disabled

    public var showProgress: Bool { self == .loading(showProgress: true) }
}
