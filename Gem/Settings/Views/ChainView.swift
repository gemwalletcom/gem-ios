// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import SwiftUI
import Style
import Components

struct ChainView: View {
    private let model: ChainViewModel

    init(chain: Chain) {
        self.model = ChainViewModel(chain: chain)
    }

    var body: some View {
        ListItemView(
            title: model.title,
            image: model.image,
            imageSize: Sizing.image.medium,
            cornerRadius: Sizing.image.medium / 2
        )
    }
}
