// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

extension Primitives.Notification: Identifiable {
    public var id: Date { createdAt }
}
