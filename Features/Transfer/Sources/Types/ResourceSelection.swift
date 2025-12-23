// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

@Observable
public final class ResourceSelection {
    public static let options: [Primitives.Resource] = [.bandwidth, .energy]
    public var selected: Primitives.Resource

    public init(selected: Primitives.Resource = .bandwidth) {
        self.selected = selected
    }
}
