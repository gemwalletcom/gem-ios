// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Style
import Localization
import Components
import PrimitivesComponents

public struct InAppNotificationListItemViewModel: Identifiable, Sendable {
    public let notification: Primitives.Notification

    public var id: Date { notification.createdAt }

    var listItemModel: ListItemModel {
        ListItemModel(
            title: title,
            titleTag: notification.isRead ? nil : Localized.Assets.Tags.new,
            titleTagStyle: titleTagStyle,
            titleExtra: titleExtra,
            subtitle: pointsText,
            subtitleStyle: pointsStyle,
            imageStyle: imageStyle
        )
    }

    private var titleTagStyle: TextStyle {
        TextStyle(font: .footnote.weight(.medium), color: .blue, background: Colors.blue.opacity(0.15))
    }

    private var title: String {
        switch notification.notificationType {
        case .referralJoined: Localized.Notifications.InApp.Referral.joinedTitle
        case .rewardsEnabled: Localized.Notifications.InApp.Rewards.enabledTitle
        case .rewardsCodeDisabled: Localized.Notifications.InApp.Rewards.disabledTitle
        }
    }

    private var titleExtra: String? {
        switch notification.notificationType {
        case .referralJoined: metadata.map { Localized.Notifications.InApp.Referral.joinedSubtitle($0.username) }
        case .rewardsEnabled: Localized.Notifications.InApp.Rewards.enabledSubtitle
        case .rewardsCodeDisabled: Localized.Notifications.InApp.Rewards.disabledSubtitle
        }
    }

    private var imageStyle: ListItemImageStyle? {
        ListItemImageStyle(
            assetImage: assetImage,
            imageSize: .image.asset,
            alignment: .top,
            cornerRadiusType: .rounded
        )
    }

    private var assetImage: AssetImage {
        let emoji: String = switch notification.notificationType {
        case .referralJoined: Emoji.party
        case .rewardsEnabled: Emoji.WalletAvatar.gift.rawValue
        case .rewardsCodeDisabled: Emoji.WalletAvatar.warning.rawValue
        }
        return AssetImage(type: emoji)
    }

    private var pointsText: String? {
        guard let points = metadata?.points, points != .zero else { return nil }
        return "+\(points) \(Emoji.gem)"
    }

    private var pointsStyle: TextStyle {
        TextStyle(font: .callout, color: Colors.black, fontWeight: .semibold)
    }

    private var metadata: NotificationRewardsMetadata? {
        notification.metadata?.decode(NotificationRewardsMetadata.self)
    }
}
