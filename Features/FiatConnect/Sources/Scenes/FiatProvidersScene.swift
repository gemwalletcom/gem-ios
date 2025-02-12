// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Primitives

public struct FiatProvidersScene: View {
    private let model: FiatProvidersViewModel

    public init(model: FiatProvidersViewModel) {
        self.model = model
    }

    public var body: some View {
        List(model.quotesViewModel) { quote in
            NavigationCustomLink(
                with: SimpleListItemView(model: quote),
                action: { model.onSelectQuote?(quote.quote) }
            )
        }
        .navigationTitle(model.title)
    }
}
