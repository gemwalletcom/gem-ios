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
    
    init(
        perpetualData: PerpetualData,
        currencyStyle: CurrencyFormatterType = .abbreviated,
        onPin: @escaping (String, Bool) -> Void
    ) {
        self.perpetualData = perpetualData
        self.currencyStyle = currencyStyle
        self.onPin = onPin
    }
    
    var body: some View {
        NavigationLink(value: Scenes.Perpetual(perpetualData)) {
            ListAssetItemView(
                model: PerpetualItemViewModel(
                    model: PerpetualViewModel(
                        perpetual: perpetualData.perpetual,
                        currencyStyle: currencyStyle
                    )
                )
            )
        }
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
