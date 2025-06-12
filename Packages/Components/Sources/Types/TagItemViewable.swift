// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI

public protocol TagItem: Identifiable, Sendable {
    var id: String { get }
}

public protocol TagItemViewable: TagItem {
    var title: String { get }
    var image: Image? { get }
    var isSelected: Bool { get }

    var id: String { get }

    var opacity: CGFloat { get }
}

public extension TagItemViewable {
    var opacity: CGFloat { isSelected ? 1.0 : 0.5 }
}
