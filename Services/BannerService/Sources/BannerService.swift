// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Store
import Primitives
import NotificationService
import UIKit

public struct BannerService: Sendable {

    private let store: BannerStore
    private let pushNotificationService: PushNotificationEnablerService

    public init(
        store: BannerStore,
        pushNotificationService: PushNotificationEnablerService
    ) {
        self.store = store
        self.pushNotificationService = pushNotificationService
    }

    public func handleAction(_ action: BannerAction) async throws {
        let result = try await {
            switch action.event {
            case .enableNotifications:
                return try await pushNotificationService.requestPermissionsOrOpenSettings()
            case .accountActivation,
                .accountBlockedMultiSignature:
                if let url = action.url {
                    await UIApplication.shared.open(url, completionHandler: .none)
                }
                return true
            case .stake:
                return false
            }
        }()
        if action.closeOnAction && result {
            try closeBanner(id: action.id)
        }
    }

    @discardableResult
    public func clearBanners() throws -> Int {
        try store.clear()
    }

    private func closeBanner(id: String) throws {
        try updateState(id: id, state: .cancelled)
    }

    private func updateState(id: String, state: BannerState) throws {
        let _ = try store.updateState(id, state: state)
    }
}


// MARK: - Actions

extension BannerService {
    public func onClose(_ banner: Banner) {
        Task { try closeBanner(id: banner.id) }
    }
}

