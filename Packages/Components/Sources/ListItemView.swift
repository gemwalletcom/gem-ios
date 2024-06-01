import SwiftUI

public struct ListItemView: View {
    
    //TODO: Refactor
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
                image
                    .resizable()
                    .frame(width: imageSize, height: imageSize)
                    .cornerRadius(cornerRadius)
            }
            if let title = title {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        Text(title)
                            .font(titleStyle.font)
                            .foregroundColor(titleStyle.color)
                            .lineLimit(1)
                            .truncationMode(.middle)
                        if let titleTag = titleTag {
                            HStack(spacing: 4) {
                                Text(titleTag)
                                    .font(titleTagStyle.font)
                                    .foregroundColor(titleTagStyle.color)
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
                            .padding(.horizontal, 4)
                            .padding(.vertical, 2)
                            .background(titleTagStyle.background)
                            .cornerRadius(6)
                        }
                    }
                    .padding(.trailing, 8)
                    
                    if let titleExtra = titleExtra {
                        Text(titleExtra)
                            .font(titleStyleExtra.font)
                            .foregroundColor(titleStyleExtra.color)
                            .padding(.trailing, 16)
                            .lineLimit(1)
                            .truncationMode(.middle)
                    }
                }
            }
            if let subtitle = subtitle {
                Spacer(minLength: 2)
                VStack(alignment: .trailing, spacing: 4) {
                    Text(subtitle)
                        .font(subtitleStyle.font)
                        .foregroundColor(subtitleStyle.color)
                        .multilineTextAlignment(.trailing)
                        .lineLimit(1)
                        .truncationMode(.middle)
                    
                    if let subtitleExtra = subtitleExtra {
                        Text(subtitleExtra)
                        .font(subtitleStyleExtra.font)
                        .foregroundColor(subtitleStyleExtra.color)
                        .multilineTextAlignment(.trailing)
                        .lineLimit(1)
                        .truncationMode(.middle)
                    }
                }
            }
        }
    }
}

struct ListItemView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            ListItemView(title: "Only title", subtitle: nil)
            ListItemView(title: "Title", subtitle: "Subtitle")
            Section {
                ListItemView(
                    title: "Title Long Title Long Title A asd nas nj nj asndjasn jdasn jn",
                    subtitle: "Subtitle"
                )
            }
        }.listStyle(.insetGrouped)
    }
}

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
