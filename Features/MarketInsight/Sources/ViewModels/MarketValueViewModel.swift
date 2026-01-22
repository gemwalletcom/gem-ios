// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Style
import InfoSheet

public struct MarketValueViewModel {
    public let title: String
    public let titleExtra: String?
    public let subtitle: String?
    public let subtitleExtra: String?
    public let subtitleExtraStyle: TextStyle?
    public let value: String?
    public let url: URL?
    public let titleTag: String?
    public let titleTagStyle: TextStyle?
    public let infoSheetType: InfoSheetType?

    public init(
        title: String,
        titleExtra: String? = .none,
        subtitle: String?,
        subtitleExtra: String? = .none,
        subtitleExtraStyle: TextStyle? = .none,
        value: String? = .none,
        url: URL? = .none,
        titleTag: String? = .none,
        titleTagStyle: TextStyle? = .none,
        infoSheetType: InfoSheetType? = .none
    ) {
        self.title = title
        self.titleExtra = titleExtra
        self.subtitle = subtitle
        self.subtitleExtra = subtitleExtra
        self.subtitleExtraStyle = subtitleExtraStyle
        self.value = value
        self.url = url
        self.titleTag = titleTag
        self.titleTagStyle = titleTagStyle
        self.infoSheetType = infoSheetType
    }
}

extension [MarketValueViewModel] {
    func withValues() -> Self { filter { $0.subtitle?.isEmpty == false } }
}
