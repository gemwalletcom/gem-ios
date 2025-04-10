// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Components
import SwiftUICore

extension ListItemImageStyle {
    static func security(_ image: Image) -> ListItemImageStyle? {
        ListItemImageStyle(
            assetImage: .image(image),
            imageSize: .image.small,
            overlayImageSize: .zero,
            cornerRadiusType: .none,
            alignment: .top
        )
    }
}
