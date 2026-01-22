// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Components
import Style
import InfoSheet

public struct AssetPriceDetailsView: View {
    private let model: AssetPriceDetailsViewModel

    @State private var isPresentingInfoSheet: InfoSheetType?

    public init(model: AssetPriceDetailsViewModel) {
        self.model = model
    }

    public var body: some View {
        List {
            marketSection(model.marketValues)
            marketSection(model.supplyValues)
            marketSection(model.allTimeValues)
        }
        .navigationTitle(model.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarDismissItem(type: .close, placement: .topBarLeading)
        .listSectionSpacing(.compact)
        .contentMargins(.top, .scene.top, for: .scrollContent)
        .sheet(item: $isPresentingInfoSheet) {
            InfoSheetScene(type: $0)
        }
    }

    @ViewBuilder
    private func marketSection(_ items: [MarketValueViewModel]) -> some View {
        if !items.isEmpty {
            Section {
                ForEach(items, id: \.title) { item in
                    ListItemView(
                        title: TextValue(text: item.title, style: .body),
                        titleExtra: item.titleExtra.map { TextValue(text: $0, style: .footnote) },
                        titleTag: item.titleTag.map { TextValue(text: $0, style: item.titleTagStyle ?? .body) },
                        subtitle: item.subtitle.map { TextValue(text: $0, style: .calloutSecondary) },
                        subtitleExtra: item.subtitleExtra.map { TextValue(text: $0, style: item.subtitleExtraStyle ?? .calloutSecondary) },
                        infoAction: item.infoSheetType.map { type in { isPresentingInfoSheet = type } }
                    )
                }
            }
        }
    }
}
