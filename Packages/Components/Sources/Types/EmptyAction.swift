// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public struct EmptyAction {
    public let title: String
    public let action: VoidAction

    public init(title: String, action: VoidAction) {
        self.title = title
        self.action = action
    }
}

extension EmptyAction: Identifiable {
    public var id: String { title }
}
