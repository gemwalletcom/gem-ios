// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style

public enum TitleTagType {
    case none
    case progressView
    case image(Image)
}

public struct ListItemView: View {
    public let title: TextValue?
    public let titleExtra: TextValue?

    public let titleTag: TextValue?
    public let titleTagType: TitleTagType

    public let subtitle: TextValue?
    public let subtitleExtra: TextValue?

    public let image: Image?
    public let imageSize: CGFloat
    public let cornerRadius: CGFloat

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
        image: Image? = nil,
        imageSize: CGFloat = 28.0,
        cornerRadius: CGFloat = 0
    ) {
        let titleValue = title.map { TextValue(text: $0, style: titleStyle) }
        let titleExtraValue = titleExtra.map { TextValue(text: $0, style: titleStyleExtra) }
        let titleTagValue = titleTag.map { TextValue(text: $0, style: titleTagStyle) }
        let subtitleValue = subtitle.map { TextValue(text: $0, style: subtitleStyle) }
        let subtitleExtraValue = subtitleExtra.map { TextValue(text: $0, style: subtitleStyleExtra) }

        self.init(
            title: titleValue,
            titleExtra: titleExtraValue,
            titleTag: titleTagValue,
            titleTagType: titleTagType,
            subtitle: subtitleValue,
            subtitleExtra: subtitleExtraValue,
            image: image,
            imageSize: imageSize,
            cornerRadius: cornerRadius
        )
    }

    public init(
        title: TextValue?,
        titleExtra: TextValue?,
        titleTag: TextValue?,
        titleTagType: TitleTagType,
        subtitle: TextValue?,
        subtitleExtra: TextValue?,
        image: Image? = nil,
        imageSize: CGFloat = 28.0,
        cornerRadius: CGFloat = 0
    ) {
        self.title = title
        self.titleExtra = titleExtra
        self.titleTag = titleTag
        self.titleTagType = titleTagType
        self.subtitle = subtitle
        self.subtitleExtra = subtitleExtra
        self.image = image
        self.imageSize = imageSize
        self.cornerRadius = cornerRadius
    }

    public var body: some View {
        HStack {
            if let image = image {
                ImageView(image: image, imageSize: imageSize, cornerRadius: cornerRadius)
            }
            if let title = title {
                TitleView(title: title, titleExtra: titleExtra, titleTag: titleTag, titleTagType: titleTagType)
            }
            if let subtitle = subtitle {
                Spacer(minLength: Spacing.extraSmall)
                SubtitleView(subtitle: subtitle, subtitleExtra: subtitleExtra)
            }
        }
    }
}

// MARK: -

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
                .frame(width: imageSize, height: imageSize)
                .cornerRadius(cornerRadius)
        }
    }
}

// MARK: -

extension ListItemView {
    struct TitleView: View {
        public let title: TextValue
        public let titleExtra: TextValue?
        public let titleTag: TextValue?
        public let titleTagType: TitleTagType

        var body: some View {
            VStack(alignment: .leading, spacing: Spacing.tiny) {
                HStack(spacing: Spacing.tiny) {
                    Text(title.text)
                        .textStyle(title.style)
                        .lineLimit(1)
                        .truncationMode(.middle)

                    if let tag = titleTag {
                        TitleTagView(titleTag: tag, titleTagType: titleTagType)
                    }
                }
                .padding(.trailing, Spacing.small)

                if let extra = titleExtra {
                    Text(extra.text)
                        .textStyle(extra.style)
                        .lineLimit(1)
                        .truncationMode(.middle)
                        .padding(.trailing, Spacing.medium)

                }
            }
        }
    }
}

// MARK: -

extension ListItemView {
    struct TitleTagView: View {
        let titleTag: TextValue
        let titleTagType: TitleTagType

        var body: some View {
            HStack(spacing: Spacing.tiny) {
                Text(titleTag.text)
                    .textStyle(titleTag.style)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                switch titleTagType {
                case .none:
                    EmptyView()
                case .progressView:
                    ListItemProgressView(size: .small, tint: titleTag.style.color)
                case .image(let image):
                    image
                }
            }
            .padding(.horizontal, Spacing.tiny)
            .padding(.vertical, Spacing.extraSmall)
            .background(titleTag.style.background)
            .cornerRadius(6)
        }
    }
}

// MARK: -

extension ListItemView {
    struct SubtitleView: View {
        public let subtitle: TextValue
        public let subtitleExtra: TextValue?

        var body: some View {
            VStack(alignment: .trailing, spacing: Spacing.tiny) {
                Text(subtitle.text)
                    .textStyle(subtitle.style)
                    .multilineTextAlignment(.trailing)
                    .lineLimit(1)
                    .truncationMode(.middle)

                if let extra = subtitleExtra {
                    Text(extra.text)
                        .textStyle(extra.style)
                        .multilineTextAlignment(.trailing)
                        .lineLimit(1)
                        .truncationMode(.middle)
                }
            }
        }
    }
}

// MARK: - Previews

#Preview {
    let defaultTitle = "Title"
    let defaultSubtitle = "Subtitle"
    let longTitle = "Long Title Long Title Long Title Long Title Long Title"
    let longSubtitle = "Long Subtitle Long Subtitle Long Subtitle Long Subtitle Long Subtitle"
    let titleExtra = "Title Extra"
    let longTitleExtra = "Long Title Extra Long Title Extra Long Title Extra Long Title Extra"
    let longSubtitleExtra = "Long Subtitle Extra Long Subtitle Extra Long Subtitle Extra"

    let defaultTextStyle = TextStyle.body
    let extraTextStyle = TextStyle.footnote
    let tagTextStyleWhite = TextStyle(font: .footnote, color: .white, background: .gray)
    let tagTextStyleBlue = TextStyle(font: Font.system(.footnote), color: .blue, background: .blue.opacity(0.2))

    return List {
        Section("Basic States") {
            ListItemView(
                title: defaultTitle,
                titleStyle: defaultTextStyle
            )
            ListItemView(
                title: defaultTitle,
                titleStyle: defaultTextStyle,
                subtitle: defaultSubtitle,
                subtitleStyle: defaultTextStyle
            )
            ListItemView(
                title: defaultTitle,
                titleStyle: defaultTextStyle,
                titleExtra: titleExtra,
                titleStyleExtra: extraTextStyle,
                subtitle: defaultSubtitle,
                subtitleStyle: defaultTextStyle
            )
        }

        Section("Long Text States") {
            ListItemView(
                title: longTitle,
                titleStyle: defaultTextStyle,
                subtitle: defaultSubtitle,
                subtitleStyle: defaultTextStyle
            )
            ListItemView(
                title: longTitle,
                titleStyle: defaultTextStyle,
                subtitle: longSubtitle,
                subtitleStyle: defaultTextStyle
            )
            ListItemView(
                title: defaultTitle,
                titleStyle: defaultTextStyle,
                titleExtra: longTitleExtra,
                titleStyleExtra: extraTextStyle,
                subtitle: defaultSubtitle,
                subtitleStyle: defaultTextStyle,
                subtitleExtra: longSubtitleExtra,
                subtitleStyleExtra: extraTextStyle
            )
        }

        Section("Tag States") {
            ListItemView(
                title: defaultTitle,
                titleStyle: defaultTextStyle, titleTag: "Tag",
                titleTagStyle: tagTextStyleWhite,
                titleTagType: .none,
                subtitle: defaultSubtitle,
                subtitleStyle: defaultTextStyle
            )
            ListItemView(
                title: defaultTitle,
                titleStyle: defaultTextStyle, titleTag: "Loading",
                titleTagStyle: tagTextStyleWhite,
                titleTagType: .progressView,
                subtitle: defaultSubtitle,
                subtitleStyle: defaultTextStyle
            )
            ListItemView(
                title: defaultTitle,
                titleStyle: defaultTextStyle, titleTag: "Image",
                titleTagStyle: tagTextStyleWhite,
                titleTagType: .image(Image(systemName: SystemImage.faceid)),
                subtitle: defaultSubtitle,
                subtitleStyle: defaultTextStyle
            )
        }

        Section("Image States") {
            ListItemView(
                title: defaultTitle,
                titleStyle: defaultTextStyle, titleTag: "Tag",
                titleTagStyle: tagTextStyleBlue,
                titleTagType: .none,
                titleExtra: titleExtra,
                titleStyleExtra: extraTextStyle, subtitle: defaultSubtitle,
                subtitleStyle: defaultTextStyle, subtitleExtra: "Subtitle Extra",
                subtitleStyleExtra: extraTextStyle, image: Image(systemName: SystemImage.faceid),
                imageSize: Sizing.list.image,
                cornerRadius: 0
            )
            ListItemView(
                title: defaultTitle,
                titleStyle: defaultTextStyle, subtitle: longSubtitle,
                subtitleStyle: defaultTextStyle, image: Image(systemName: SystemImage.eye),
                imageSize: Sizing.list.image,
                cornerRadius: 0
            )
        }

        Section("Combined States") {
            ListItemView(
                title: defaultTitle,
                titleStyle: defaultTextStyle, titleTag: "Loading",
                titleTagStyle: tagTextStyleBlue,
                titleTagType: .progressView,
                titleExtra: titleExtra,
                titleStyleExtra: extraTextStyle, subtitle: longSubtitle,
                subtitleStyle: defaultTextStyle
            )
            ListItemView(
                title: defaultTitle,
                titleStyle: defaultTextStyle, titleTag: "Image",
                titleTagStyle: tagTextStyleBlue,
                titleTagType: .image(Image(systemName: SystemImage.faceid)),
                titleExtra: titleExtra,
                titleStyleExtra: extraTextStyle, subtitle: defaultSubtitle,
                subtitleStyle: defaultTextStyle, subtitleExtra: longSubtitleExtra,
                subtitleStyleExtra: extraTextStyle
            )
        }

        Section("Additional Scenarios") {
            ListItemView(
                title: "Large Title with No Subtitle, Tag, or Extra",
                titleStyle: TextStyle(font: Font.system(.headline), color: .red)
            )
            ListItemView(
                title: defaultTitle,
                titleStyle: defaultTextStyle, image: Image(systemName: SystemImage.eye),
                imageSize: Sizing.list.image,
                cornerRadius: 0
            )
        }
    }.listStyle(.insetGrouped)
}
