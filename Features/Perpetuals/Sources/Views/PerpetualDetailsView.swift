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

                ListItemView(
                    title: model.executionPriceTitle,
                    subtitle: model.executionPriceText
                )

                ListItemView(
                    title: model.sizeTitle,
                    subtitle: model.sizeText
                )

                ListItemView(
                    title: model.notionalValueTitle,
                    subtitle: model.notionalValueText
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
