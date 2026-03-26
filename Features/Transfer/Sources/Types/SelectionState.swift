// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

@Observable
public final class SelectionState<T> {
    public let options: [T]
    public var selected: T
    public let isEnabled: Bool
    public let title: String

    public init(
        options: [T],
        selected: T,
        isEnabled: Bool,
        title: String
    ) {
        self.options = options
        self.selected = selected
        self.isEnabled = isEnabled
        self.title = title
    }
}
