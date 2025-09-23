// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Primitives

public struct CurrencyScene: View {
    @State private var model: CurrencySceneViewModel

    public init(model: CurrencySceneViewModel) {
        self.model = model
    }

    public var body: some View {
        List(model.list) { section in
            Section(section.section) {
                ForEach(section.values) {
                    ListItemSelectionView(
                        title: $0.title,
                        titleExtra: .none,
                        titleTag: .none,
                        titleTagType: .none,
                        subtitle: .none,
                        subtitleExtra: .none,
                        value: $0.value.currency,
                        selection: model.currency
                    ) {
                        try? model.setCurrency($0)
                    }
                }
            }
        }
        .listSectionSpacing(.compact)
        .navigationTitle(model.title)
    }
}
