// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Components

struct GridPosterViewItem: Identifiable {
    let id: String
    let destination: any Hashable
    let assetImage: AssetImage
    let title: String
}
