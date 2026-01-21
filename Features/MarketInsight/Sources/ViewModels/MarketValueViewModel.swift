// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Style

public struct MarketValueViewModel {
    public let title: String
    public let subtitle: String?
    public let subtitleExtra: String?
    public let value: String?
    public let url: URL?
    public let titleTag: String?
    public let titleTagStyle: TextStyle?

    public init(
        title: String,
        subtitle: String?,
        subtitleExtra: String? = .none,
        value: String? = .none,
        url: URL? = .none,
        titleTag: String? = .none,
        titleTagStyle: TextStyle? = .none
    ) {
        self.title = title
        self.subtitle = subtitle
        self.subtitleExtra = subtitleExtra
        self.value = value
        self.url = url
        self.titleTag = titleTag
        self.titleTagStyle = titleTagStyle
    }
}
