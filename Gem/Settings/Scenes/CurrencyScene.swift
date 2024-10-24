// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Primitives

struct CurrencyScene: View {
    @ObservedObject var model: CurrencySceneViewModel
    
    init(
        model: CurrencySceneViewModel
    ) {
        self.model = model
    }
    
    var body: some View {
        List {
            ForEach(model.list) { section in
                Section(section.section) {
                    ForEach(section.values) { currency in
                        ListItemSelectionView(
                            title: currency.title,
                            titleExtra: .none,
                            titleTag: .none,
                            titleTagType: .none,
                            subtitle: .none,
                            subtitleExtra: .none,
                            value: currency.value,
                            selection: model.currency
                        ) {
                            onSelect(currency: $0)
                        }
                    }
                }
            }
        }
        .listSectionSpacing(.compact)
        .navigationTitle(model.title)
    }
}

// MARK: - Actions

extension CurrencyScene {
    private func onSelect(currency: String) {
        model.currency = currency
    }
}

// MARK: - Previews

#Preview {
    NavigationStack {
        CurrencyScene(model: .init(preferences: .main))
            .navigationBarTitleDisplayMode(.inline)
    }
}
