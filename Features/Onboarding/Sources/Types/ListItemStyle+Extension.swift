// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Components
import SwiftUICore

extension ListItemImageStyle {
    static func security(_ image: Image) -> ListItemImageStyle? {
        ListItemImageStyle(
            assetImage: .image(image),
            imageSize: .image.small,
            alignment: .top,
            cornerRadiusType: .none
        )
    }
}
