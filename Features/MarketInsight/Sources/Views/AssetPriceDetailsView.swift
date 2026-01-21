// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Components
import Store
import Style

public struct AssetPriceDetailsView: View {
    @State private var model: AssetPriceDetailsViewModel

    public init(model: AssetPriceDetailsViewModel) {
        _model = State(initialValue: model)
    }

    public var body: some View {
        List {
            Section {
                ForEach(model.marketValues, id: \.title) { item in
                    ListItemView(
                        title: item.title,
                        titleTag: item.titleTag,
                        titleTagStyle: item.titleTagStyle ?? .body,
                        subtitle: item.subtitle,
                        subtitleExtra: item.subtitleExtra
                    )
                }
            }
        }
        .observeQuery(request: $model.priceRequest, value: $model.priceData)
        .navigationTitle(model.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarDismissItem(type: .close, placement: .topBarLeading)
        .listSectionSpacing(.compact)
        .contentMargins(.top, .scene.top, for: .scrollContent)
    }
}
