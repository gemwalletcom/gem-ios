// Copyright (c). Gem Wallet. All rights reserved.

import Style
import SwiftUI

public enum TitleTagType {
    case none
    case progressView(scale: CGFloat = 1.0)
    case image(Image)
}

public enum ListItemViewPlaceholderType: Identifiable, CaseIterable {
    // items supports placeholder progress view
    case subtitle // right corner of cell

    public var id: Self { self }
}

public struct ListItemModel {
    public struct StyleDefaults {
        public static let titleStyle: TextStyle = .body
        public static let titleTagStyle: TextStyle = .body
        public static let titleExtraStyle: TextStyle = .footnote
        public static let subtitleStyle: TextStyle = .calloutSecondary
        public static let subtitleExtraStyle: TextStyle = .calloutSecondary
    }
    
    public struct TitleConfiguration {
        let title: TextValue
        let titleExtra: TextValue?
        let titleTag: TextValue?
        let titleTagType: TitleTagType
        let infoAction: (() -> Void)?
    }

    public let title: String?
    public let titleStyle: TextStyle
    public let titleTag: String?
    public let titleTagStyle: TextStyle
    public let titleTagType: TitleTagType
    public let titleExtra: String?
    public let titleStyleExtra: TextStyle
    public let subtitle: String?
    public let subtitleStyle: TextStyle
    public let subtitleExtra: String?
    public let subtitleStyleExtra: TextStyle
    public let imageStyle: ListItemImageStyle?
    public let placeholders: [ListItemViewPlaceholderType]
    public let infoAction: (() -> Void)?

    public init(
        title: String? = nil,
        titleStyle: TextStyle = StyleDefaults.titleStyle,
        titleTag: String? = nil,
        titleTagStyle: TextStyle = StyleDefaults.titleTagStyle,
        titleTagType: TitleTagType = .none,
        titleExtra: String? = nil,
        titleStyleExtra: TextStyle = StyleDefaults.titleExtraStyle,
        subtitle: String? = nil,
        subtitleStyle: TextStyle = StyleDefaults.subtitleStyle,
        subtitleExtra: String? = nil,
        subtitleStyleExtra: TextStyle = StyleDefaults.subtitleExtraStyle,
        imageStyle: ListItemImageStyle? = nil,
        placeholders: [ListItemViewPlaceholderType] = [],
        infoAction: (() -> Void)? = nil
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

    public var titleTextValue: TextValue? { title.map { TextValue(text: $0, style: titleStyle, lineLimit: 1) } }
    public var titleExtraTextValue: TextValue? { titleExtra.map { TextValue(text: $0, style: titleStyleExtra, lineLimit: nil) } }
    public var titleTagTextValue: TextValue? { titleTag.map { TextValue(text: $0, style: titleTagStyle, lineLimit: 1) } }
    public var subtitleTextValue: TextValue? { subtitle.map { TextValue(text: $0, style: subtitleStyle, lineLimit: 1) } }
    public var subtitleExtraTextValue: TextValue? { subtitleExtra.map { TextValue(text: $0, style: subtitleStyleExtra, lineLimit: 1) } }

    public var titleView: TextValue? { titleTextValue }
    public var subtitleView: TextValue? { 
        showPlaceholderProgress(for: .subtitle, value: subtitleTextValue) ? nil : subtitleTextValue 
    }

    public var titleConfiguration: TitleConfiguration? {
        titleView.map {
            TitleConfiguration(
                title: $0,
                titleExtra: titleExtraTextValue,
                titleTag: titleTagTextValue,
                titleTagType: titleTagType,
                infoAction: infoAction
            )
        }
    }
    
    public var imageAlignment: VerticalAlignment { imageStyle?.alignment ?? .center }

    public var loadingTintColor: Color { subtitleTextValue?.style.color ?? Colors.gray }

    public var hasSubtitlePlaceholder: Bool { showPlaceholderProgress(for: .subtitle, value: subtitleTextValue) }

    public func showPlaceholderProgress(for type: ListItemViewPlaceholderType, value: Any?) -> Bool { placeholders.contains(type) && value == nil }
}

// MARK: - Factory Methods

public extension ListItemModel {
    static func text(title: String, subtitle: String? = nil) -> ListItemModel {
        ListItemModel(title: title, subtitle: subtitle)
    }
}
