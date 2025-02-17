// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Gemstone
import Components
import Primitives
import BigInt
import Preferences
import Localization

struct SwapProvidersScene: View {
    @Environment(\.dismiss) private var dismiss

    let model: SwapProvidersViewModel

    var body: some View {
        List(model.items) { item in
            NavigationCustomLink(
                with: SimpleListItemView(model: item),
                action: {
                    model.onSelectQuote?(item.swapQuote)
                    dismiss()
                }
            )
        }
        .navigationTitle(Localized.Buy.Providers.title)
    }
}
