// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

@Observable
public final class ResourceSelection {
    public static let options: [Resource] = [.bandwidth, .energy]
    public var selected: Resource

    public init(selected: Resource = .bandwidth) {
        self.selected = selected
    }
}
