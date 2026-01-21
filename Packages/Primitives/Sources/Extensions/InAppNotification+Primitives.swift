// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

extension Primitives.InAppNotification: Identifiable {
    public var id: String { item.id }
    public var isRead: Bool { readAt != nil }
}
