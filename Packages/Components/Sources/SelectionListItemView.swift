// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Style
import SwiftUI

public struct SelectionListItemView: View {
    public enum SelectionImageDirection: Identifiable {
        case left
        case right

        public var id: Self { self }
    }

    let title: String?
    let titleExtra: String?
    let subtitle: String?
    let subtitleExtra: String?
    let value: String?
    let selection: String?
    let action: ((String) -> Void)?

    let placeholders: [ListItemViewPlaceholderType]
    let selectionDirection: SelectionImageDirection

    public init(
        title: String?,
        titleExtra: String?,
        subtitle: String?,
        subtitleExtra: String?,
        placeholders: [ListItemViewPlaceholderType] = [],
        selectionDirection: SelectionImageDirection = .right,
        value: String?,
        selection: String?,
        action: ((String) -> Void)?
    ) {
        self.title = title
        self.titleExtra = titleExtra
        self.subtitle = subtitle
        self.subtitleExtra = subtitleExtra
        self.placeholders = placeholders
        self.selectionDirection = selectionDirection
        self.value = value
        self.selection = selection
        self.action = action
    }

    public var body: some View {
        Button(action: {
            if let value = value {
                action?(value)
            }
        }, label: {
            HStack {
                if selectionDirection == .left {
                    selectionImageView
                }
                ListItemView(
                    title: title,
                    titleExtra: titleExtra,
                    subtitle: subtitle,
                    subtitleExtra: subtitleExtra,
                    placeholders: placeholders
                )
                Spacer()
                if selectionDirection == .right {
                    selectionImageView
                }
            }
        })
        .contentShape(Rectangle())
    }

    private var selectionImageView: some View {
        ZStack {
            if selection == value {
                Image(systemName: SystemImage.checkmark)
            }
        }
        .frame(width: Sizing.list.image)
    }
}
