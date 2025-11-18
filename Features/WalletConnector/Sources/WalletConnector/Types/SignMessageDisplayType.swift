// Copyright (c). Gem Wallet. All rights reserved.

import Components
import Primitives
import struct Gemstone.SiweMessage

public enum SignMessageDisplayType: Sendable {
    case sections([ListSection<KeyValueItem>])
    case text(String)
    case siwe(SiweMessage)
}
