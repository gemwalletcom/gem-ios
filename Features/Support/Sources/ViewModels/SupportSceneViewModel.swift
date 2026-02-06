// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Localization
import GemstonePrimitives
import Primitives
import NotificationService

@Observable
@MainActor
public final class SupportSceneViewModel: Sendable {
    var selectedType: SupportType = .support
    var isPresentingSupport: Binding<Bool>

    private let pushNotificationService: PushNotificationEnablerService
    private let deviceId: String

    public init(
        pushNotificationService: PushNotificationEnablerService = PushNotificationEnablerService(),
        deviceId: String,
        isPresentingSupport: Binding<Bool>
    ) {
        self.isPresentingSupport = isPresentingSupport
        self.pushNotificationService = pushNotificationService
        self.deviceId = deviceId
    }

    var title: String { Localized.Settings.support }
    var helpCenterURL: URL { Docs.url(.start) }

    var chatwootModel: ChatwootWebViewModel {
        return ChatwootWebViewModel(
            websiteToken: Constants.Support.chatwootPublicToken,
            baseUrl: Constants.Support.chatwootURL,
            deviceId: deviceId,
            domainPolicy: Constants.Support.domainPolicy,
            isPresentingSupport: isPresentingSupport
        )
    }

    func requestPushNotifications() async {
        do {
            _ = try await pushNotificationService.requestPermissions()
        } catch {
            debugLog("Failed to request push notifications: \(error)")
        }
    }
}

// MARK: - Actions

extension SupportSceneViewModel {
    func onDismiss() {
        isPresentingSupport.wrappedValue = false
    }
}
