// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import Components

public struct AssetsTagsView: View {
    private let model: AssetTagsViewModel
    private let onSelect: (AssetTagViewModel) -> Void

    public init(model: AssetTagsViewModel, onSelect: @escaping (AssetTagViewModel) -> Void) {
        self.model = model
        self.onSelect = onSelect
    }

    public var body: some View {
        if model.items.isEmpty {
            EmptyView()
        } else {
            TagsView(
                tags: model.items,
                onSelect: onSelect
            )
        }
    }
}
