// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives

struct PerpetualSectionView: View {
    let perpetuals: [PerpetualData]
    let onPin: (String, Bool) -> Void
    let emptyText: String?

    init(
        perpetuals: [PerpetualData],
        onPin: @escaping (String, Bool) -> Void,
        emptyText: String? = nil
    ) {
        self.perpetuals = perpetuals
        self.onPin = onPin
        self.emptyText = emptyText
    }

    var body: some View {
        if perpetuals.isEmpty, let emptyText {
            Text(emptyText)
                .foregroundColor(.secondary)
        } else {
            ForEach(perpetuals) { perpetualData in
                PerpetualListItem(
                    perpetualData: perpetualData,
                    onPin: onPin
                )
            }
        }
    }
}