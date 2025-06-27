// Copyright (c). Gem Wallet. All rights reserved.

import Components
import Primitives

public enum SignMessageDisplayType: Sendable {
    case sections([ListSection<KeyValueItem>])
    case text(String)
}
