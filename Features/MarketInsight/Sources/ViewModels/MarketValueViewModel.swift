// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Style
import InfoSheet
import PrimitivesComponents

struct MarketValueViewModel {
    enum Action {
        case none
        case explorer(ExplorerContextData)
        case info(InfoSheetType)
    }

    let title: String
    let titleExtra: String?
    let subtitle: String?
    let subtitleExtra: String?
    let subtitleExtraStyle: TextStyle?
    let action: Action
    let titleTag: String?
    let titleTagStyle: TextStyle?

    init(
        title: String,
        titleExtra: String? = .none,
        subtitle: String?,
        subtitleExtra: String? = .none,
        subtitleExtraStyle: TextStyle? = .none,
        action: Action = .none,
        titleTag: String? = .none,
        titleTagStyle: TextStyle? = .none
    ) {
        self.title = title
        self.titleExtra = titleExtra
        self.subtitle = subtitle
        self.subtitleExtra = subtitleExtra
        self.subtitleExtraStyle = subtitleExtraStyle
        self.action = action
        self.titleTag = titleTag
        self.titleTagStyle = titleTagStyle
    }
}

extension [MarketValueViewModel] {
    func withValues() -> Self { filter { $0.subtitle?.isEmpty == false } }
}
