// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Components

struct InsightLink {

    let title: String
    let subtitle: String?
    var url: URL
    let deepLink: URL?
    let image: AssetImage

    init(
        title: String,
        subtitle: String?,
        url: URL,
        deepLink: URL?,
        image: AssetImage
    ) {
        self.title = title
        self.subtitle = subtitle
        self.url = url
        self.deepLink = deepLink
        self.image = image
    }
}

extension InsightLink: Identifiable {
    var id: String { title + url.absoluteString }
}
