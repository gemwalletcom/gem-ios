// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Components
import SwiftUICore

extension ListItemImageStyle {
    static func security(_ emoji: String) -> ListItemImageStyle? {
        ListItemImageStyle(
            assetImage: AssetImage(type: emoji),
            imageSize: .image.semiMedium,
            alignment: .top,
            cornerRadiusType: .none
        )
    }
}
