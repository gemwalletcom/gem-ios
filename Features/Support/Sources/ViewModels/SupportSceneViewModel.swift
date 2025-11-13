// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Localization
import GemstonePrimitives
import Preferences
import Primitives
import NotificationService
import GemAPI

@Observable
@MainActor
public final class SupportSceneViewModel: Sendable {
    var selectedType: SupportType = .support
    var isPresentingSupport: Binding<Bool>
    
    private let pushNotificationService: PushNotificationEnablerService
    private let supportService: SupportService
    
    public init(
        pushNotificationService: PushNotificationEnablerService = PushNotificationEnablerService(),
        supportService: SupportService = SupportService(),
        isPresentingSupport: Binding<Bool>
    ) {
        self.isPresentingSupport = isPresentingSupport
        self.pushNotificationService = pushNotificationService
        self.supportService = supportService
    }
    
    var title: String { Localized.Settings.support }
    var helpCenterURL: URL { Docs.url(.start) }
    
    var chatwootModel: ChatwootWebViewModel {
        return ChatwootWebViewModel(
            websiteToken: Constants.chatwootPublicToken,
            baseUrl: Constants.chatwootURL,
            supportDeviceId: supportService.getOrCreateSupportDeviceId(),
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
    
    public func registerSupport() async {
        do {
            try await supportService.registerSupportDeviceIfNeeded()
        } catch {
            debugLog("registerSupport error \(error)")
        }
    }
}

// MARK: - Actions

extension SupportSceneViewModel {
    func onDismiss() {
        isPresentingSupport.wrappedValue = false
    }
}
