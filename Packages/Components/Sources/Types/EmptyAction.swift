// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public struct EmptyAction {
    public let title: String
    public let action: (() -> Void)?

    public init(title: String, action: (() -> Void)?) {
        self.title = title
        self.action = action
    }
}

extension EmptyAction: Identifiable {
    public var id: String { title }
}
