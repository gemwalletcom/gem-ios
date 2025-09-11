// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Localization
import GemstonePrimitives
import Preferences
import Primitives
import NotificationService

@Observable
@MainActor
public final class SupportSceneViewModel: Sendable {
    var selectedType: SupportType = .support
    var isPresentingSupport: Binding<Bool>
    
    private let pushNotificationService: PushNotificationEnablerService
    
    public init(
        pushNotificationService: PushNotificationEnablerService = PushNotificationEnablerService(),
        isPresentingSupport: Binding<Bool>
    ) {
        self.isPresentingSupport = isPresentingSupport
        self.pushNotificationService = pushNotificationService
    }
    
    var title: String { Localized.Settings.support }
    var helpCenterURL: URL { Docs.url(.start) }
    
    var chatwootModel: ChatwootWebViewModel {
        ChatwootWebViewModel(
            websiteToken: "9xwzqya1JR7Q4rcoZRurkjch",
            baseUrl: URL(string: "https://app.chatwoot.com")!,
            deviceId: try? SecurePreferences().get(key: .deviceId),
            isPresentingSupport: isPresentingSupport
        )
    }
    
    func requestPushNotifications() async {
        do {
            _ = try await pushNotificationService.requestPermissions()
        } catch {
            print("Failed to request push notifications: \(error)")
        }
    }
}

// MARK: - Actions

extension SupportSceneViewModel {
    func onDismiss() {
        isPresentingSupport.wrappedValue = false
    }
}
