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
        let canClose = try await {
            switch action.type {
            case let .event(event):
                switch event {
                case .enableNotifications:
                    try await pushNotificationService.requestPermissionsOrOpenSettings()
                case .stake, .activateAsset, .suspiciousAsset, .onboarding, .accountActivation, .accountBlockedMultiSignature, .tradePerpetuals, .earn:
                    false
                }
            case .closeBanner: true
            case .button: false
            }
        }()
        if canClose {
            try closeBanner(id: action.id)
        }
    }

    @discardableResult
    public func clearBanners() throws -> Int {
        try store.clear()
    }

    @discardableResult
    public func activateAllCancelledBanners() throws -> Int {
        try store.updateStates(from: .cancelled, to: .active)
    }

    private func updateState(id: String, state: BannerState) throws {
        try store.updateState(id, state: state)
    }
}


// MARK: - Actions

extension BannerService {
    public func closeBanner(id: String) throws {
        try updateState(id: id, state: .cancelled)
    }

    public func onClose(_ banner: Banner) {
        Task { try closeBanner(id: banner.id) }
    }
}
