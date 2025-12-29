// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

@Observable
public final class ResourceSelection {
    public let options: [Resource]
    public var selected: Resource

    public init(
        options: [Resource] = [.bandwidth, .energy],
        selected: Resource = .bandwidth
    ) {
        self.options = options
        self.selected = selected
    }
}
