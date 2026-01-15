// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Components
import Localization
import NotificationService
import PrimitivesComponents
import Store

@Observable
@MainActor
public final class InAppNotificationsViewModel {
    private let notificationService: InAppNotificationService
    private let wallet: Wallet

    public var request: InAppNotificationsRequest
    public var notifications: [Primitives.Notification] = []
    public var state: StateViewType<[ListSection<InAppNotificationListItemViewModel>]> = .loading

    public init(
        wallet: Wallet,
        notificationService: InAppNotificationService
    ) {
        self.wallet = wallet
        self.notificationService = notificationService
        self.request = InAppNotificationsRequest(walletIdType: (try? wallet.walletIdType()) ?? "")
    }

    public var title: String { Localized.Settings.Notifications.title }

    public var emptyContentModel: EmptyContentTypeViewModel {
        EmptyContentTypeViewModel(type: .notifications)
    }

    private var sections: [ListSection<InAppNotificationListItemViewModel>] {
        let grouped = Dictionary(grouping: notifications) {
            Calendar.current.startOfDay(for: $0.createdAt)
        }
        return grouped.keys.sorted(by: >).compactMap { date in
            guard let items = grouped[date] else { return nil }
            return ListSection(
                id: date.ISO8601Format(),
                title: TransactionDateFormatter(date: date).section,
                image: nil,
                values: items.map { InAppNotificationListItemViewModel(notification: $0) }
            )
        }
    }

    private var hasUnreadNotifications: Bool {
        notifications.contains { !$0.isRead }
    }
}

// MARK: - Actions

extension InAppNotificationsViewModel {
    public func updateState() {
        state = notifications.isEmpty ? .noData : .data(sections)
    }

    public func update() async {
        do {
            try await notificationService.update()
            await markAsRead()
        } catch {
            state = .error(error)
            debugLog("update notifications error: \(error)")
        }
    }

    public func markAsRead() async {
        if hasUnreadNotifications {
            do {
                try await notificationService.markNotificationsRead()
            } catch {
                debugLog("markAsRead error: \(error)")
            }
        }
    }
}
