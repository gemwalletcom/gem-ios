// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Primitives

public struct FiatProvidersScene: View {
    private let model: FiatProvidersViewModel
    private let onSelectQuote: ((FiatQuote) -> Void)?

    public init(
        model: FiatProvidersViewModel,
        onSelectQuote: ((FiatQuote) -> Void)?
    ) {
        self.model = model
        self.onSelectQuote = onSelectQuote
    }

    public var body: some View {
        List(model.quotesViewModel) { quote in
            NavigationCustomLink(
                with: SimpleListItemView(model: quote),
                action: { onSelectQuote?(quote.quote) }
            )
        }
        .navigationTitle(model.title)
    }
}
