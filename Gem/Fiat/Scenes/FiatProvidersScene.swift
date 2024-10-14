// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Style
import Localization

struct FiatProvidersScene: View {
    
    @Environment(\.dismiss) private var dismiss

    let model: FiatProvidersViewModel
    
    var body: some View {
        List(model.quotesViewModel) { quote in
            NavigationCustomLink(
                with: ListItemView(
                    title: quote.title,
                    subtitle: quote.amount,
                    image: Image(quote.image),
                    imageSize: Sizing.image.chain,
                    cornerRadius: Sizing.image.chain/2
                )
            ) {
                model.selectQuote?(quote.quote)
                dismiss()
            }
        }
        .navigationTitle(Localized.Buy.Providers.title)
    }
}
