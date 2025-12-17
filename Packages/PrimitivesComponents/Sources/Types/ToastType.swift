// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public enum ToastType: Sendable {
    case perpetualAutoclose
    case perpetualClose
    case perpetualOrder(PerpetualPositionAction)
}
