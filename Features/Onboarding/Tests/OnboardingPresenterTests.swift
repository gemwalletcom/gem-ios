// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Primitives
import PrimitivesTestKit
import InfoSheet

@testable import Onboarding

@MainActor
struct OnboardingPresenterTests {
    let presenter = OnboardingPresenter()

    @Test
    func showEnablePushNotificationsWhenFirstWallet() {
        presenter.showEnablePushNotificationsIfNeeded(
            oldWallet: nil,
            newWallet: .mock(),
            isPushNotificationsEnabled: false
        )

        #expect(presenter.isPresentingInfoSheetAction == .enablePushNotifications)
    }

    @Test
    func hideWhenNotFirstWallet() {
        presenter.showEnablePushNotificationsIfNeeded(
            oldWallet: .mock(),
            newWallet: .mock(),
            isPushNotificationsEnabled: false
        )

        #expect(presenter.isPresentingInfoSheetAction == nil)
    }

    @Test
    func hideWhenPushNotificationsEnabled() {
        presenter.showEnablePushNotificationsIfNeeded(
            oldWallet: nil,
            newWallet: .mock(),
            isPushNotificationsEnabled: true
        )

        #expect(presenter.isPresentingInfoSheetAction == nil)
    }
}
