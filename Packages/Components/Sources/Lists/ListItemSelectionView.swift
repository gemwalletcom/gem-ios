// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style

public struct ListItemSelectionView<T: Hashable>: View {
    let title: String?
    let titleExtra: String?
    let subtitle: String?
    let subtitleExtra: String?

    let titleTag: String?
    let titleTagType: TitleTagType
    let titleTagStyle: TextStyle
    
    let imageStyle: AssetImageStyle?
    
    let value: T?
    let selection: T?
    let action: ((T) -> Void)?

    let placeholders: [ListItemViewPlaceholderType]

    public init(
        title: String?,
        titleExtra: String?,
        titleTag: String?,
        titleTagType: TitleTagType,
        titleTagStyle: TextStyle = .body,
        subtitle: String?,
        subtitleExtra: String?,
        imageStyle: AssetImageStyle? = nil,
        placeholders: [ListItemViewPlaceholderType] = [],
        value: T,
        selection: T?,
        action: ((T) -> Void)?
    ) {
        self.title = title
        self.titleExtra = titleExtra
        self.titleTag = titleTag
        self.titleTagType = titleTagType
        self.titleTagStyle = titleTagStyle
        self.subtitle = subtitle
        self.subtitleExtra = subtitleExtra
        self.imageStyle = imageStyle
        self.placeholders = placeholders
        self.value = value
        self.selection = selection
        self.action = action
    }

    public var body: some View {
         SelectionView(
             value: value,
             selection: selection,
             action: action
         ) {
             ListItemView(
                 title: title,
                 titleTag: titleTag,
                 titleTagStyle: titleTagStyle,
                 titleTagType: titleTagType,
                 titleExtra: titleExtra,
                 subtitle: subtitle,
                 subtitleExtra: subtitleExtra,
                 imageStyle: imageStyle,
                 placeholders: placeholders
             )
         }
     }
}
