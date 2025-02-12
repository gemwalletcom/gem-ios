// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public enum SecretPhraseDataType {
    case words(words: [[WordIndex]])
    case privateKey(key: String)
}
