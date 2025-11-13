// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import InfoSheet
import Preferences

@Observable
public final class OnboardingPresenter: Sendable {
    @MainActor
    public var isPresentingInfoSheetAction: InfoSheetActionType?

    public init() { }

    @MainActor
    public func showEnablePushNotifications() {
        guard Preferences.standard.isPushNotificationsEnabled == false else { return }
        isPresentingInfoSheetAction = .enablePushNotifications
    }
}
