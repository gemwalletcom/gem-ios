// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Style

public struct ListAssetHeaderView<Model: AssetPreviewable>: View {
    private let model: Model
    private let subtitleLayout: AssetPreviewView<Model>.SubtitleLayout

    public init(model: Model, subtitleLayout: AssetPreviewView<Model>.SubtitleLayout = .horizontal) {
        self.model = model
        self.subtitleLayout = subtitleLayout
    }

    public var body: some View {
        Section { } header: {
            AssetPreviewView(model: model, subtitleLayout: subtitleLayout)
                .frame(maxWidth: .infinity)
                .padding(.bottom, .small)
        }
        .cleanListRow()
    }
}
