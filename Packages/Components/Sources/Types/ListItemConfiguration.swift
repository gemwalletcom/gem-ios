// Copyright (c). Gem Wallet. All rights reserved.

import Style
import SwiftUI

public struct ListItemConfiguration {
    public var title: String?
    public var titleStyle: TextStyle
    public var titleTag: String?
    public var titleTagStyle: TextStyle
    public var titleTagType: TitleTagType
    public var titleExtra: String?
    public var titleStyleExtra: TextStyle
    public var subtitle: String?
    public var subtitleStyle: TextStyle
    public var subtitleExtra: String?
    public var subtitleStyleExtra: TextStyle
    public var imageStyle: ListItemImageStyle?
    public var placeholders: [ListItemViewPlaceholderType]
    public var infoAction: (@MainActor @Sendable () -> Void)?

    public init(
        title: String? = nil,
        titleStyle: TextStyle = .body,
        titleTag: String? = nil,
        titleTagStyle: TextStyle = .body,
        titleTagType: TitleTagType = .none,
        titleExtra: String? = nil,
        titleStyleExtra: TextStyle = .footnote,
        subtitle: String? = nil,
        subtitleStyle: TextStyle = .calloutSecondary,
        subtitleExtra: String? = nil,
        subtitleStyleExtra: TextStyle = .calloutSecondary,
        imageStyle: ListItemImageStyle? = nil,
        placeholders: [ListItemViewPlaceholderType] = [],
        infoAction: (@MainActor @Sendable () -> Void)? = nil
    ) {
        self.title = title
        self.titleStyle = titleStyle
        self.titleTag = titleTag
        self.titleTagStyle = titleTagStyle
        self.titleTagType = titleTagType
        self.titleExtra = titleExtra
        self.titleStyleExtra = titleStyleExtra
        self.subtitle = subtitle
        self.subtitleStyle = subtitleStyle
        self.subtitleExtra = subtitleExtra
        self.subtitleStyleExtra = subtitleStyleExtra
        self.imageStyle = imageStyle
        self.placeholders = placeholders
        self.infoAction = infoAction
    }
}
