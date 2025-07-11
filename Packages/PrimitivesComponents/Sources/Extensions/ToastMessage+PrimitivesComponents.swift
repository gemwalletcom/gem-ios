// Copyright (c). Gem Wallet. All rights reserved.

import Components
import Localization
import Style

public extension ToastMessage {
    static func copied(_ value: String) -> ToastMessage {
        ToastMessage(title: Localized.Common.copied(value), image: SystemImage.copy)
    }
}