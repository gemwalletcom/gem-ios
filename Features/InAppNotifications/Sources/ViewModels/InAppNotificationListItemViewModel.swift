// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Style
import Localization
import Components
import PrimitivesComponents

public struct InAppNotificationListItemViewModel: Identifiable, Sendable {
    public let notification: Primitives.InAppNotification

    public var id: String { notification.id }

    var listItemModel: ListItemModel {
        ListItemModel(
            title: notification.item.title,
            titleTag: notification.isRead ? nil : Localized.Assets.Tags.new,
            titleTagStyle: titleTagStyle,
            titleExtra: notification.item.subtitle,
            subtitle: notification.item.value,
            subtitleStyle: pointsStyle,
            imageStyle: imageStyle
        )
    }

    private var titleTagStyle: TextStyle {
        TextStyle(font: .footnote.weight(.medium), color: .blue, background: Colors.blue.opacity(0.15))
    }

    private var imageStyle: ListItemImageStyle? {
        guard let assetImage else { return nil }
        return ListItemImageStyle(
            assetImage: assetImage,
            imageSize: .image.asset,
            alignment: .top,
            cornerRadiusType: .rounded
        )
    }

    private var assetImage: AssetImage? {
        guard let icon = notification.item.icon else { return nil }
        switch icon {
        case .emoji(let coreEmoji):
            let emoji: String = switch coreEmoji {
            case .gift: Emoji.WalletAvatar.gift.rawValue
            case .gem: Emoji.gem
            case .party: Emoji.party
            case .warning: Emoji.WalletAvatar.warning.rawValue
            }
            return AssetImage(type: emoji)
        case .asset(let assetId):
            return AssetIdViewModel(assetId: assetId).assetImage
        case .image(let url):
            return AssetImage(imageURL: URL(string: url))
        }
    }

    private var pointsStyle: TextStyle {
        TextStyle(font: .callout, color: Colors.black, fontWeight: .semibold)
    }
}
