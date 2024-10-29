// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import SwiftUI
import Style
import Components

struct ChainView: View {
    let chain: Chain

    var body: some View {
        ListItemView(
            title: Asset(chain).name,
            image: Images.name(chain.id),
            imageSize: Sizing.image.medium,
            cornerRadius: Sizing.image.medium/2
        )
    }
}
