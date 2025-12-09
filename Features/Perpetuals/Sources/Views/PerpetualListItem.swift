// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import Components
import PrimitivesComponents
import Formatters

struct PerpetualListItem: View {
    let perpetualData: PerpetualData
    let currencyStyle: CurrencyFormatterType
    let onPin: (String, Bool) -> Void
    let onSelect: (Asset) -> Void

    init(
        perpetualData: PerpetualData,
        currencyStyle: CurrencyFormatterType = .abbreviated,
        onPin: @escaping (String, Bool) -> Void,
        onSelect: @escaping (Asset) -> Void
    ) {
        self.perpetualData = perpetualData
        self.currencyStyle = currencyStyle
        self.onPin = onPin
        self.onSelect = onSelect
    }

    var body: some View {
        NavigationCustomLink(
            with: ListAssetItemView(
                model: PerpetualItemViewModel(
                    model: PerpetualViewModel(
                        perpetual: perpetualData.perpetual,
                        currencyStyle: currencyStyle
                    )
                )
            ),
            action: { onSelect(perpetualData.asset) }
        )
        .listRowInsets(.assetListRowInsets)
        .contextMenu(
            [
                .pin(
                    isPinned: perpetualData.metadata.isPinned,
                    onPin: {
                        onPin(perpetualData.perpetual.id, !perpetualData.metadata.isPinned)
                    }
                )
            ]
        )
    }
}
