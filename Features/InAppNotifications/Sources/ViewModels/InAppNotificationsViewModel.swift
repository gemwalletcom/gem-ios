// Copyright (c). Gem Wallet. All rights reserved.

import Components
import Foundation
import Localization
import NotificationService
import Primitives
import PrimitivesComponents
import Store
import UIKit

@Observable
@MainActor
public final class InAppNotificationsViewModel {
    private let notificationService: InAppNotificationService
    private let wallet: Wallet

    public let query: ObservableQuery<InAppNotificationsRequest>
    public var notifications: [Primitives.InAppNotification] { query.value }

    public init(
        wallet: Wallet,
        notificationService: InAppNotificationService
    ) {
        self.wallet = wallet
        self.notificationService = notificationService
        self.query = ObservableQuery(InAppNotificationsRequest(walletId: wallet.id), initialValue: [])
    }

    public var title: String { Localized.Settings.Notifications.title }

    public var emptyContentModel: EmptyContentTypeViewModel {
        EmptyContentTypeViewModel(type: .notifications)
    }

    public var sections: [ListSection<InAppNotificationListItemViewModel>] {
        DateSectionBuilder(
            items: notifications,
            dateKeyPath: \.createdAt,
            transform: { InAppNotificationListItemViewModel(notification: $0) }
        ).build()
    }

    private var hasUnreadNotifications: Bool {
        notifications.contains { !$0.isRead }
    }
}

// MARK: - Actions

extension InAppNotificationsViewModel {
    public func fetch() async {
        do {
            try await notificationService.update(walletId: wallet.walletId)
            if hasUnreadNotifications {
                await markAsRead()
            }
        } catch {
            debugLog("fetch notifications error: \(error)")
        }
    }

    private func markAsRead() async {
        do {
            try await notificationService.markNotificationsRead()
        } catch {
            debugLog("markAsRead error: \(error)")
        }
    }

    public func open(url: URL) {
        UIApplication.shared.open(url)
    }
}
