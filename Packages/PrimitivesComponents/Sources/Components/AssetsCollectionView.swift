// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import Components
import Style

public struct AssetsCollectionView<Content: View>: View {
    private let models: [AssetViewModel]
    private let content: (AssetViewModel) -> Content

    public init(
        models: [AssetViewModel],
        @ViewBuilder content: @escaping (AssetViewModel) -> Content
    ) {
        self.models = models
        self.content = content
    }

    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.small) {
                ForEach(models, id: \.asset.id) { model in
                    content(model)
                }
            }
        }
    }
}

public struct AssetChipView: View {
    private let model: AssetViewModel

    public init(model: AssetViewModel) {
        self.model = model
    }

    public var body: some View {
        HStack(spacing: .tiny) {
            AssetImageView(
                assetImage: model.assetImage,
                size: .list.image
            )
            Text(model.symbol)
                .textStyle(TextStyle(font: .body, color: .primary, fontWeight: .semibold))
        }
        .padding(.small)
        .background(Colors.listStyleColor, in: RoundedRectangle(cornerRadius: .list.image / 2 + .small))
    }
}
