// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

@Observable
final class SelectionState<T> {
    let options: [T]
    var selected: T
    let isEnabled: Bool
    let title: String

    init(
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
