// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Style
import Localization
import FiatConnect
import Style

struct FiatProvidersScene: View {
    
    @Environment(\.dismiss) private var dismiss

    let model: FiatProvidersViewModel
    
    var body: some View {
        List(model.quotesViewModel) { quote in
            NavigationCustomLink(
                with: ListItemView(
                    title: quote.title,
                    subtitle: quote.amountText,
                    image: Images.name(quote.image),
                    imageSize: Sizing.image.medium,
                    cornerRadius: Sizing.image.medium/2
                )
            ) {
                model.selectQuote?(quote.quote)
                dismiss()
            }
        }
        .navigationTitle(Localized.Buy.Providers.title)
    }
}
