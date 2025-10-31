// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import InfoSheet

@Observable
public final class OnboardingPresenter: Sendable {
    @MainActor
    public var isPresentingInfoSheetAction: InfoSheetActionType?

    public init() { }

    @MainActor
    public func showEnablePushNotificationsIfNeeded(oldWallet: Wallet?, newWallet: Wallet?, isPushNotificationsEnabled: Bool) {
        guard oldWallet == nil, newWallet != nil, !isPushNotificationsEnabled else { return }
        isPresentingInfoSheetAction = .enablePushNotifications
    }
}
