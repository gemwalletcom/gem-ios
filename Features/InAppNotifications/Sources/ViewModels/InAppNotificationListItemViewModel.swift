// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Style
import Localization
import Components
import PrimitivesComponents

public struct InAppNotificationListItemViewModel: Identifiable, Sendable {
    private let item: CoreListItem
    private let isRead: Bool

    public let id: String
    public let url: URL?

    public init(notification: InAppNotification) {
        self.id = notification.id
        self.item = notification.item
        self.isRead = notification.isRead
        self.url = notification.item.url?.asURL
    }

    var listItemModel: ListItemModel {
        ListItemModel(
            title: item.title,
            titleTag: isRead ? nil : Localized.Assets.Tags.new,
            titleTagStyle: TextStyle(font: .footnote.weight(.medium), color: .blue, background: Colors.blue.opacity(.light)),
            titleExtra: item.subtitle,
            subtitle: item.value,
            subtitleStyle: TextStyle(font: .callout, color: Colors.black, fontWeight: .semibold),
            subtitleExtra: item.subvalue,
            imageStyle: imageStyle
        )
    }

    private var imageStyle: ListItemImageStyle? {
        guard let icon = item.icon else { return nil }
        return ListItemImageStyle(
            assetImage: assetImage(for: icon),
            imageSize: .image.asset,
            alignment: .top,
            cornerRadiusType: .rounded
        )
    }

    private func assetImage(for icon: CoreListItemIcon) -> AssetImage {
        switch icon {
        case .emoji(let emoji): AssetImage(type: emoji.value)
        case .asset(let assetId): AssetIdViewModel(assetId: assetId).assetImage
        case .image(let url): AssetImage(imageURL: url.asURL)
        }
    }
}

private extension CoreEmoji {
    var value: String {
        switch self {
        case .gift: Emoji.WalletAvatar.gift.rawValue
        case .gem: Emoji.gem
        case .party: Emoji.party
        case .warning: Emoji.WalletAvatar.warning.rawValue
        }
    }
}
