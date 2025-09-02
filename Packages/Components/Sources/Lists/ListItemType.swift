// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style

// MARK: - Core ListItemType Enum

public enum ListItemType {
    case basic(title: String, subtitle: String? = nil)
    case image(title: String, subtitle: String? = nil, image: AssetImage)
    case detailed(title: String, titleExtra: String? = nil, subtitle: String, subtitleExtra: String? = nil)
    case tag(title: String, subtitle: String? = nil, tag: String, tagStyle: TextStyle)
    case loading(title: String, placeholders: [ListItemViewPlaceholderType])
    case custom(ListItemConfiguration)
    case empty
}

// MARK: - ListItemConfiguration

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

// MARK: - ListItemType to Configuration

extension ListItemType {
    public var configuration: ListItemConfiguration {
        switch self {
        case let .basic(title, subtitle):
            ListItemConfiguration(
                title: title,
                subtitle: subtitle
            )

        case let .image(title, subtitle, image):
            ListItemConfiguration(
                title: title,
                subtitle: subtitle,
                imageStyle: .list(assetImage: image)
            )

        case let .detailed(title, titleExtra, subtitle, subtitleExtra):
            ListItemConfiguration(
                title: title,
                titleExtra: titleExtra,
                subtitle: subtitle,
                subtitleExtra: subtitleExtra
            )

        case let .tag(title, subtitle, tag, tagStyle):
            ListItemConfiguration(
                title: title,
                titleTag: tag,
                titleTagStyle: tagStyle,
                subtitle: subtitle
            )

        case let .loading(title, placeholders):
            ListItemConfiguration(
                title: title,
                placeholders: placeholders
            )

        case let .custom(configuration):
            configuration

        case .empty:
            ListItemConfiguration()
        }
    }
}

// MARK: - Unified Protocol

public protocol ListItemViewable {
    var listItemModel: ListItemType { get }
}

// MARK: - View Extension

public extension ListItemView {
    init(type: ListItemType) {
        let config = type.configuration
        self.init(
            title: config.title,
            titleStyle: config.titleStyle,
            titleTag: config.titleTag,
            titleTagStyle: config.titleTagStyle,
            titleTagType: config.titleTagType,
            titleExtra: config.titleExtra,
            titleStyleExtra: config.titleStyleExtra,
            subtitle: config.subtitle,
            subtitleStyle: config.subtitleStyle,
            subtitleExtra: config.subtitleExtra,
            subtitleStyleExtra: config.subtitleStyleExtra,
            imageStyle: config.imageStyle,
            placeholders: config.placeholders,
            infoAction: config.infoAction
        )
    }
    init(model: any ListItemViewable) {
        self.init(type: model.listItemModel)
    }
}

// MARK: - Factory Methods

public extension ListItemType {
    /// Factory method for settings items with an icon
    static func settingsItem(title: String, subtitle: String? = nil, image: AssetImage) -> Self {
        .image(title: title, subtitle: subtitle, image: image)
    }

    /// Factory method for financial amounts with optional fiat conversion
    static func financialAmount(title: String, amount: String, fiatAmount: String? = nil) -> Self {
        .detailed(title: title, titleExtra: nil, subtitle: amount, subtitleExtra: fiatAmount)
    }

    /// Factory method for items with info actions
    static func withInfo(title: String, subtitle: String, info: @escaping @MainActor @Sendable () -> Void) -> Self {
        .custom(ListItemConfiguration(
            title: title,
            subtitle: subtitle,
            infoAction: info
        ))
    }

    /// Factory method for status items with custom styling
    static func status(
        title: String,
        status: String,
        statusStyle: TextStyle,
        info: (@MainActor @Sendable () -> Void)? = nil
    ) -> Self {
        .custom(ListItemConfiguration(
            title: title,
            subtitle: status,
            subtitleStyle: statusStyle,
            infoAction: info
        ))
    }
}
