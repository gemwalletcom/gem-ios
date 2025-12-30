// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

@MainActor
public final class RecentsSceneViewModel {
    public let models: [AssetViewModel]
    public let onSelect: (Asset) -> Void

    public init(
        models: [AssetViewModel],
        onSelect: @escaping (Asset) -> Void
    ) {
        self.models = models
        self.onSelect = onSelect
    }
}
