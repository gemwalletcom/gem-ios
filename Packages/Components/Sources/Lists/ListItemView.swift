// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style

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

public struct ListItemView: View {
    public let title: TextValue?
    public let titleExtra: TextValue?

    public let titleTag: TextValue?
    public let titleTagType: TitleTagType

    public let subtitle: TextValue?
    public let subtitleExtra: TextValue?

    public let imageStyle: ListItemImageStyle?

    public var infoAction: (() -> Void)?

    public let placeholders: [ListItemViewPlaceholderType]

    public init(
        title: String? = nil,
        titleStyle: TextStyle = TextStyle.body,
        titleTag: String? = nil,
        titleTagStyle: TextStyle = TextStyle.body,
        titleTagType: TitleTagType = .none,
        titleExtra: String? = nil,
        titleStyleExtra: TextStyle = TextStyle.footnote,
        subtitle: String? = nil,
        subtitleStyle: TextStyle = TextStyle.calloutSecondary,
        subtitleExtra: String? = nil,
        subtitleStyleExtra: TextStyle = TextStyle.calloutSecondary,
        imageStyle: ListItemImageStyle? = nil,
        placeholders: [ListItemViewPlaceholderType] = [],
        infoAction: (() -> Void)? = nil
    ) {
        let titleValue = title.map { TextValue(text: $0, style: titleStyle, lineLimit: 1) }
        let titleExtraValue = titleExtra.map { TextValue(text: $0, style: titleStyleExtra, lineLimit: nil) }
        let titleTagValue = titleTag.map { TextValue(text: $0, style: titleTagStyle, lineLimit: 1) }
        let subtitleValue = subtitle.map { TextValue(text: $0, style: subtitleStyle, lineLimit: 1) }
        let subtitleExtraValue = subtitleExtra.map { TextValue(text: $0, style: subtitleStyleExtra, lineLimit: 1) }

        self.init(
            title: titleValue,
            titleExtra: titleExtraValue,
            titleTag: titleTagValue,
            titleTagType: titleTagType,
            subtitle: subtitleValue,
            subtitleExtra: subtitleExtraValue,
            imageStyle: imageStyle,
            placeholders: placeholders,
            infoAction: infoAction
        )
    }

    public init(
        title: TextValue? = nil,
        titleExtra: TextValue? = nil,
        titleTag: TextValue? = nil,
        titleTagType: TitleTagType = .none,
        subtitle: TextValue? = nil,
        subtitleExtra: TextValue? = nil,
        imageStyle: ListItemImageStyle? = nil,
        showInfo: Bool = false,
        placeholders: [ListItemViewPlaceholderType] = [],
        infoAction: (() -> Void)? = nil
    ) {
        self.title = title
        self.titleExtra = titleExtra
        self.titleTag = titleTag
        self.titleTagType = titleTagType
        self.subtitle = subtitle
        self.subtitleExtra = subtitleExtra
        self.imageStyle = imageStyle
        self.placeholders = placeholders
        self.infoAction = infoAction
    }

    public var body: some View {
        HStack(alignment: imageStyle?.alignment ?? .center, spacing: .space12) {
            if let imageStyle {
                AssetImageView(
                    assetImage: imageStyle.assetImage,
                    size: imageStyle.imageSize,
                    cornerRadius: imageStyle.cornerRadius
                )
            }
            HStack {
                if let title {
                    TitleView(
                        title: title,
                        titleExtra: titleExtra,
                        titleTag: titleTag,
                        titleTagType: titleTagType,
                        infoAction: infoAction
                    )
                    .listRowInsets(.zero)
                }

                if showPlaceholderProgress(for: .subtitle, value: subtitle) {
                    Spacer()
                    LoadingView(tint: subtitle?.style.color ?? Colors.gray)
                } else if let subtitle = subtitle {
                    Spacer(minLength: .extraSmall)
                    SubtitleView(subtitle: subtitle, subtitleExtra: subtitleExtra)
                }
            }
        }
    }
}

// MARK: - Private

extension ListItemView {
    private func showPlaceholderProgress(for type: ListItemViewPlaceholderType, value: Any?) -> Bool {
        placeholders.contains(type) && value == nil
    }
}

// MARK: - UI Components

// MARK: - Image

extension ListItemView {
    struct ImageView: View {
        let image: Image
        let imageSize: CGFloat
        let cornerRadius: CGFloat

        init(image: Image, imageSize: CGFloat, cornerRadius: CGFloat) {
            self.image = image
            self.imageSize = imageSize
            self.cornerRadius = cornerRadius
        }

        var body: some View {
            return image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: imageSize, height: imageSize)
                .cornerRadius(cornerRadius)
        }
    }
}

// MARK: - TitleView

extension ListItemView {
    struct TitleView: View {
        public let title: TextValue
        public let titleExtra: TextValue?
        public let titleTag: TextValue?
        public let titleTagType: TitleTagType
        public let infoAction: (() -> Void)?

        var body: some View {
            VStack(alignment: .leading, spacing: .tiny) {
                HStack(spacing: .tiny) {
                    Text(title.text)
                        .textStyle(title.style)
                        .lineLimit(title.lineLimit)
                        .truncationMode(.tail)

                    if let infoAction {
                        InfoButton(
                            action: infoAction
                        )
                    }

                    if let titleTag {
                        TitleTagView(titleTag: titleTag, titleTagType: titleTagType)
                    }
                }

                if let extra = titleExtra {
                    Text(extra.text)
                        .textStyle(extra.style)
                        .lineLimit(extra.lineLimit)
                }
            }
            .padding(.trailing, .small)
        }
    }
}

// MARK: - TitleTagView

extension ListItemView {
    struct TitleTagView: View {
        let titleTag: TextValue
        let titleTagType: TitleTagType

        var body: some View {
            HStack(spacing: .tiny) {
                Text(titleTag.text)
                    .textStyle(titleTag.style)
                    .lineLimit(titleTag.lineLimit)
                    .minimumScaleFactor(0.8)

                switch titleTagType {
                case .none:
                    EmptyView()
                case let .progressView(scale):
                    LoadingView(size: .small, tint: titleTag.style.color)
                        .scaleEffect(scale)
                case .image(let image):
                    image
                }
            }
            .padding(.horizontal, .tiny)
            .padding(.vertical, .extraSmall)
            .background(titleTag.style.background)
            .cornerRadius(6)
        }
    }
}

// MARK: - ListItemView

extension ListItemView {
    struct SubtitleView: View {
        public let subtitle: TextValue
        public let subtitleExtra: TextValue?

        var body: some View {
            VStack(alignment: .trailing, spacing: .tiny) {
                Text(subtitle.text)
                    .textStyle(subtitle.style)
                    .multilineTextAlignment(.trailing)
                    .lineLimit(subtitle.lineLimit)
                    .truncationMode(.middle)

                if let extra = subtitleExtra {
                    Text(extra.text)
                        .textStyle(extra.style)
                        .multilineTextAlignment(.trailing)
                        .lineLimit(extra.lineLimit)
                        .truncationMode(.middle)
                }
            }
        }
    }
}

public extension ListItemView {
    init(type: ListItemType) {
        switch type {
        case let .text(title, subtitle):
            self.init(
                title: title,
                subtitle: subtitle
            )
        case let .custom(config):
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
        case .empty:
            self.init()
        }
    }
}


// MARK: - Previews

#Preview {
    List {
        Section("ListItemType Cases") {
            // .text cases
            ListItemView(type: .text(title: "Simple Title"))
            ListItemView(type: .text(title: "Title with Subtitle", subtitle: "This is a subtitle"))
            ListItemView(type: .text(title: "Long Title Long Title Long Title", subtitle: "Long Subtitle Long Subtitle"))
            ListItemView(type: .custom(ListItemConfiguration(
                title: "Custom with Tag",
                titleTag: "NEW",
                titleTagStyle: TextStyle(font: .footnote, color: .white, background: .blue),
                subtitle: "Custom configuration example"
            )))
            
            ListItemView(type: .custom(ListItemConfiguration(
                title: "With Image",
                subtitle: "Custom with left image",
                imageStyle: .list(assetImage: AssetImage.image(Images.System.faceid))
            )))
            
            ListItemView(type: .custom(ListItemConfiguration(
                title: "Loading State",
                placeholders: [.subtitle]
            )))

            ListItemView(type: .empty)
        }
        
        Section("Complex Custom Examples") {
            ListItemView(type: .custom(ListItemConfiguration(
                title: "Full Featured",
                titleTag: "PRO",
                titleTagStyle: TextStyle(font: .footnote, color: .white, background: .purple),
                titleTagType: .image(Images.System.book),
                titleExtra: "Extra info",
                subtitle: "Main subtitle",
                subtitleExtra: "Extra subtitle",
                imageStyle: .list(assetImage: AssetImage.image(Images.System.eye))
            )))
        }
    }.listStyle(.insetGrouped)
}
