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
        case .referralJoined: Localized.Notifications.Inapp.Referral.Joined.title
        case .rewardsEnabled: Localized.Notifications.Inapp.Rewards.Enabled.title
        case .rewardsCodeDisabled: Localized.Notifications.Inapp.Rewards.Disabled.title
        case .rewardsRedeemed: Localized.Notifications.Inapp.Rewards.Redeemed.title
        case .rewardsCreateUsername: Localized.Rewards.CreateReferralCode.title
        case .rewardsInvite: Localized.Rewards.InviteFriends.title
        }
    }

    private var titleExtra: String? {
        switch notification.notificationType {
        case .referralJoined: metadata.map { Localized.Notifications.Inapp.Referral.Joined.subtitle($0.username) }
        case .rewardsEnabled: Localized.Notifications.Inapp.Rewards.Enabled.subtitle
        case .rewardsCodeDisabled: Localized.Notifications.Inapp.Rewards.Disabled.subtitle
        case .rewardsRedeemed: Localized.Notifications.Inapp.Rewards.Redeemed.subtitle
        case .rewardsCreateUsername: Localized.Notifications.Inapp.Rewards.CreateUsername.subtitle
        case .rewardsInvite: Localized.Notifications.Inapp.Rewards.Invite.subtitle
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
        case .rewardsRedeemed: Emoji.WalletAvatar.check.rawValue
        case .rewardsCreateUsername: Emoji.WalletAvatar.star.rawValue
        case .rewardsInvite: Emoji.WalletAvatar.magic.rawValue
        }
        return AssetImage(type: emoji)
    }

    private var pointsText: String? {
        guard let points = metadata?.points, points != .zero else { return nil }
        let sign = points >= 0 ? "+" : "-"
        return "\(sign)\(abs(points)) \(Emoji.gem)"
    }

    private var pointsStyle: TextStyle {
        TextStyle(font: .callout, color: Colors.black, fontWeight: .semibold)
    }

    private var metadata: NotificationRewardsMetadata? {
        notification.metadata?.decode(NotificationRewardsMetadata.self)
    }
}
