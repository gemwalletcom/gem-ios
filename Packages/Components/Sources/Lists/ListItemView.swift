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
                        .truncationMode(.middle)

                    if let infoAction {
                        Button(action: infoAction) {
                            Images.System.info
                                .font(title.style.font)
                                .foregroundStyle(Colors.gray)
                        }
                        .buttonStyle(.plain)
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
                titleStyle: defaultTextStyle,
                titleTag: "Tag",
                titleTagStyle: tagTextStyleWhite,
                titleTagType: .none,
                subtitle: defaultSubtitle,
                subtitleStyle: defaultTextStyle
            )
            ListItemView(
                title: defaultTitle,
                titleStyle: defaultTextStyle,
                titleTag: "Loading",
                titleTagStyle: tagTextStyleWhite,
                titleTagType: .progressView(),
                subtitle: defaultSubtitle,
                subtitleStyle: defaultTextStyle
            )
            ListItemView(
                title: defaultTitle,
                titleStyle: defaultTextStyle,
                titleTag: "Image",
                titleTagStyle: tagTextStyleWhite,
                titleTagType: .image(Images.System.faceid),
                subtitle: defaultSubtitle,
                subtitleStyle: defaultTextStyle
            )
        }

        Section("Image States") {
            ListItemView(
                title: defaultTitle,
                titleStyle: defaultTextStyle,
                titleTag: "Tag",
                titleTagStyle: tagTextStyleBlue,
                titleTagType: .none,
                titleExtra: titleExtra,
                titleStyleExtra: extraTextStyle,
                subtitle: defaultSubtitle,
                subtitleStyle: defaultTextStyle,
                subtitleExtra: "Subtitle Extra",
                subtitleStyleExtra: extraTextStyle,
                imageStyle: .list(assetImage: AssetImage.image(Images.System.faceid))
            )
            ListItemView(
                title: defaultTitle,
                titleStyle: defaultTextStyle,
                subtitle: longSubtitle,
                subtitleStyle: defaultTextStyle,
                imageStyle: .list(assetImage: AssetImage.image(Images.System.eye))
            )
        }

        Section("Combined States") {
            ListItemView(
                title: defaultTitle,
                titleStyle: defaultTextStyle,
                titleTag: "Loading",
                titleTagStyle: tagTextStyleBlue,
                titleTagType: .progressView(),
                titleExtra: titleExtra,
                titleStyleExtra: extraTextStyle,
                subtitle: longSubtitle,
                subtitleStyle: defaultTextStyle
            )
            ListItemView(
                title: defaultTitle,
                titleStyle: defaultTextStyle,
                titleTag: "Image",
                titleTagStyle: tagTextStyleBlue,
                titleTagType: .image(Images.System.faceid),
                titleExtra: titleExtra,
                titleStyleExtra: extraTextStyle,
                subtitle: defaultSubtitle,
                subtitleStyle: defaultTextStyle,
                subtitleExtra: longSubtitleExtra,
                subtitleStyleExtra: extraTextStyle
            )
        }

        Section("Loadable States") {
            ListItemView(
                title: defaultTitle,
                titleStyle: defaultTextStyle,
                placeholders: [.subtitle]
            )
        }

        Section("Additional Scenarios") {
            ListItemView(
                title: "Large Title with No Subtitle, Tag, or Extra",
                titleStyle: TextStyle(font: Font.system(.headline), color: .red)
            )
            ListItemView(
                title: defaultTitle,
                titleStyle: defaultTextStyle,
                imageStyle: .list(assetImage: AssetImage.image(Images.System.eye))
            )
        }
    }.listStyle(.insetGrouped)
}
