// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Style
import InfoSheet

struct MarketValueViewModel {
    let title: String
    let titleExtra: String?
    let subtitle: String?
    let subtitleExtra: String?
    let subtitleExtraStyle: TextStyle?
    let value: String?
    let url: URL?
    let titleTag: String?
    let titleTagStyle: TextStyle?
    let infoSheetType: InfoSheetType?

    init(
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
