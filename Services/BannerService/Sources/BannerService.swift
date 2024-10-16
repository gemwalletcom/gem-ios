// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Store
import Primitives
import NotificationService

public actor BannerService {

    private let store: BannerStore
    private let pushNotificationService: PushNotificationEnablerService

    public init(
        store: BannerStore,
        pushNotificationService: PushNotificationEnablerService
    ) {
        self.store = store
        self.pushNotificationService = pushNotificationService
    }

    public func handleAction(banner: Banner) async throws {
        let result = try await {
            switch banner.event {
            case .enableNotifications:
                return try await pushNotificationService.requestPermissions()
            case .stake, .accountActivation:
                return true
            }
        }()
        if banner.closeOnAction && result {
            try closeBanner(banner: banner)
        }
    }

    public func clearBanners() throws -> Int {
        try store.clear()
    }

    private func closeBanner(banner: Banner) throws {
        try updateState(banner: banner, state: .cancelled)
    }

    private func updateState(banner: Banner, state: BannerState) throws {
        let _ = try store.updateState(banner.id, state: state)
    }
}


// MARK: - Actions

extension BannerService {
    public nonisolated func onAction(banner: Banner) {
        Task { try await handleAction(banner: banner) }
    }

    public nonisolated func onClose(banner: Banner) {
        Task { try await closeBanner(banner: banner) }
    }
}
