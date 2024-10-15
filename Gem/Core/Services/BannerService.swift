// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Store
import Primitives

struct BannerService {

    let store: BannerStore

    private let pushNotificationService = PushNotificationEnablerService(preferences: .main)

    init(store: BannerStore) {
        self.store = store
    }

    func handleAction(banner: Banner) async throws {
        switch banner.event {
        case .enableNotifications:
            let _ = try await pushNotificationService.requestPermissions()
        case .stake, .accountActivation:
            break
        }

        if banner.closeOnAction {
            try closeBanner(banner: banner)
        }
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
    func onAction(banner: Banner) {
        Task { try await handleAction(banner: banner) }
    }

    func onClose(banner: Banner) {
        Task { try closeBanner(banner: banner) }
    }
}
