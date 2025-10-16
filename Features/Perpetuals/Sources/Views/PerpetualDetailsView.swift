// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Components
import PrimitivesComponents
import InfoSheet
import Localization
import Primitives

public struct PerpetualDetailsView: View {
    private var model: PerpetualDetailsViewModel

    public init(model: PerpetualDetailsViewModel) {
        self.model = model
    }

    public var body: some View {
        List {
            Section {
                ListItemView(
                    title: model.directionTitle,
                    subtitle: model.directionText,
                    subtitleStyle: model.listItemModel.subtitleStyle
                )

                if let pnlText = model.pnlText {
                    ListItemView(
                        title: model.pnlTitle,
                        subtitle: pnlText,
                        subtitleStyle: model.pnlTextStyle
                    )
                }
                
                ListItemView(
                    title: model.marginTitle,
                    subtitle: model.marginText
                )

                ListItemView(
                    title: model.leverageTitle,
                    subtitle: model.leverageText
                )

                ListItemView(
                    title: model.marketPriceTitle,
                    subtitle: model.marketPriceText
                )

                if let entryPriceText = model.entryPriceText {
                    ListItemView(
                        title: model.entryPriceTitle,
                        subtitle: entryPriceText
                    )
                }

                ListItemView(
                    title: model.slippageTitle,
                    subtitle: model.slippageText
                )
            }
        }
        .toolbarDismissItem(title: .done, placement: .topBarLeading)
        .navigationTitle(Localized.Common.details)
        .navigationBarTitleDisplayMode(.inline)
        .listSectionSpacing(.compact)
        .contentMargins([.top], .extraSmall, for: .scrollContent)
    }
}
