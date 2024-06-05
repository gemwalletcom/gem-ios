import SwiftUI
import Style

public struct ListItemView: View {

    public let title: String?
    public let titleStyle: TextStyle
    public let titleExtra: String?
    public let titleStyleExtra: TextStyle
    public let titleTag: String?
    public let titleTagStyle: TextStyle
    public let titleTagType: TitleTagType

    public let subtitle: String?
    public let subtitleStyle: TextStyle
    public let subtitleExtra: String?
    public let subtitleStyleExtra: TextStyle

    public let image: Image?
    public let imageSize: CGFloat
    public let cornerRadius: CGFloat

    public init(
        title: String?,
        titleStyle: TextStyle = TextStyle(font: Font.system(.body), color: .primary),
        titleTag: String? = .none,
        titleTagStyle: TextStyle = TextStyle(font: Font.system(.body), color: .primary),
        titleTagType: TitleTagType = .none,
        titleExtra: String? = .none,
        titleStyleExtra: TextStyle = TextStyle(font: Font.system(.footnote), color: .secondary),
        subtitle: String? = .none,
        subtitleStyle: TextStyle = TextStyle(font: Font.system(.callout), color: .secondary),
        subtitleExtra: String? = .none,
        subtitleStyleExtra: TextStyle = TextStyle(font: Font.system(.callout), color: .secondary),
        image: Image? = .none,
        imageSize: CGFloat = 28.0,
        cornerRadius: CGFloat = 0
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
                TitleView(title: title, titleStyle: titleStyle, titleTag: titleTag, titleTagStyle: titleTagStyle, titleTagType: titleTagType, titleExtra: titleExtra, titleStyleExtra: titleStyleExtra)
            }
            if let subtitle = subtitle {
                Spacer(minLength: Spacing.extraSmall)
                SubtitleView(subtitle: subtitle, subtitleStyle: subtitleStyle, subtitleExtra: subtitleExtra, subtitleStyleExtra: subtitleStyleExtra)
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
        let title: String
        let titleStyle: TextStyle
        let titleTag: String?
        let titleTagStyle: TextStyle
        let titleTagType: TitleTagType
        let titleExtra: String?
        let titleStyleExtra: TextStyle

        var body: some View {
            VStack(alignment: .leading, spacing: Spacing.tiny) {
                HStack(spacing: Spacing.tiny) {
                    Text(title)
                        .font(titleStyle.font)
                        .foregroundStyle(titleStyle.color)
                        .lineLimit(1)
                        .truncationMode(.middle)

                    if let tag = titleTag {
                        TitleTagView(titleTag: tag, titleTagStyle: titleTagStyle, titleTagType: titleTagType)
                    }
                }
                .padding(.trailing, Spacing.small)

                if let extra = titleExtra {
                    Text(extra)
                        .font(titleStyleExtra.font)
                        .foregroundStyle(titleStyleExtra.color)
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
        let titleTag: String
        let titleTagStyle: TextStyle
        let titleTagType: TitleTagType

        var body: some View {
            HStack(spacing: Spacing.tiny) {
                Text(titleTag)
                    .font(titleTagStyle.font)
                    .foregroundStyle(titleTagStyle.color)
                    .lineLimit(1)

                switch titleTagType {
                case .none:
                    EmptyView()
                case .progressView:
                    ListItemProgressView(size: .small, tint: titleTagStyle.color)
                case .image(let image):
                    image
                }
            }
            .padding(.horizontal, Spacing.tiny)
            .padding(.vertical, Spacing.extraSmall)
            .background(titleTagStyle.background)
            .cornerRadius(6)
        }
    }
}

// MARK: -

extension ListItemView {
    struct SubtitleView: View {
        let subtitle: String
        let subtitleStyle: TextStyle
        let subtitleExtra: String?
        let subtitleStyleExtra: TextStyle

        var body: some View {
            VStack(alignment: .trailing, spacing: Spacing.tiny) {
                Text(subtitle)
                    .font(subtitleStyle.font)
                    .foregroundStyle(subtitleStyle.color)
                    .multilineTextAlignment(.trailing)
                    .lineLimit(1)
                    .truncationMode(.middle)

                if let extra = subtitleExtra {
                    Text(extra)
                        .font(subtitleStyleExtra.font)
                        .foregroundStyle(subtitleStyleExtra.color)
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

    let defaultTextStyle = TextStyle(font: Font.system(.body), color: .primary)
    let extraTextStyle = TextStyle(font: Font.system(.footnote), color: .secondary)
    let tagTextStyleWhite = TextStyle(font: Font.system(.footnote), color: .white, background: .gray)
    let tagTextStyleBlue = TextStyle(font: Font.system(.footnote), color: .blue, background: .blue.opacity(0.2))

    return List {
        // Basic States
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

        // Long Text States
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

        // Tag States
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

        // Image States
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

        // Combined States
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

        // Additional Scenarios
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

// TODO: - disscuss and maybe move this later somewhere

public struct ListItemValue<T> {
    public let title: String?
    public let subtitle: String?
    public let value: T

    public init(title: String? = .none, subtitle: String? = .none, value: T) {
        self.title = title
        self.subtitle = subtitle
        self.value = value
    }
}

extension ListItemValue: Identifiable {
    public var id: String { title ?? subtitle ?? ""}
}

public struct ListItemValueSection<T> {
    public let section: String
    public let values: [ListItemValue<T>]

    public init(section: String, values: [ListItemValue<T>]) {
        self.section = section
        self.values = values
    }
}

extension ListItemValueSection: Identifiable {
    public var id: String { section }
}

public enum TitleTagType {
    case none
    case progressView
    case image(Image)
}

public struct ListItemProgressView: View {

    public let size: ControlSize
    public let tint: Color

    public init(size: ControlSize, tint: Color) {
        self.size = size
        self.tint = tint
    }

    public var body: some View {
        ProgressView()
            .controlSize(size)
            .progressViewStyle(.circular)
            .tint(tint)
    }
}
