// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import PrimitivesComponents
import Components

public struct PerpetualPositionsList: View {
    private let positions: [PerpetualPositionData]
    private let onSelect: AssetAction

    public init(
        positions: [PerpetualPositionData],
        onSelect: AssetAction = nil
    ) {
        self.positions = positions
        self.onSelect = onSelect
    }

    public var body: some View {
        ForEach(positions) { position in
            if let onSelect {
                NavigationCustomLink(
                    with: listItem(for: position),
                    action: { onSelect(position.perpetualData.asset) }
                )
            } else {
                NavigationLink(value: Scenes.Perpetual(position.perpetualData)) {
                    listItem(for: position)
                }
            }
        }
    }

    private func listItem(for position: PerpetualPositionData) -> ListAssetItemView {
        ListAssetItemView(
            model: PerpetualPositionItemViewModel(
                model: PerpetualPositionViewModel(position)
            )
        )
    }
}
