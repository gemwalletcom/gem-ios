// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Primitives
import NotificationService
import DeviceService
import Components
import Style
import Localization
import BannerService
import InfoSheet

@Observable
@MainActor
public final class EnablePushNotificationsViewModel {

    private let pushNotificationService: PushNotificationEnablerService
    private let deviceService: DeviceService
    private let bannerService: BannerService
    private var isPresented: Binding<Bool>

    var buttonState = ButtonState.normal
    var isPresentingAlertMessage: AlertMessage?

    public init(
        pushNotificationService: PushNotificationEnablerService = PushNotificationEnablerService(),
        deviceService: DeviceService,
        bannerService: BannerService,
        isPresented: Binding<Bool>
    ) {
        self.pushNotificationService = pushNotificationService
        self.deviceService = deviceService
        self.bannerService = bannerService
        self.isPresented = isPresented
    }

    var infoSheetModel: InfoSheetModel {
        InfoSheetModel(
            title: Localized.Banner.EnableNotifications.title,
            description: "Turn on notifications to keep up with your wallet activity. You can change this anytime in Settings.",
            image: .assetImage(AssetImage(type: Emoji.bell)),
            button: .action(
                title: Localized.Settings.enableValue(""),
                action: onEnable
            )
        )
    }
}

// MARK: - Actions

extension EnablePushNotificationsViewModel {
    func onEnable() {
        buttonState = .loading(showProgress: true)

        Task {
            do {
                let isEnabled = try await pushNotificationService.requestPermissions()
                if isEnabled {
                    try await deviceService.update()
                    try bannerService.closeBanner(id: BannerEvent.enableNotifications.rawValue)
                }
                isPresented.wrappedValue = false
            } catch {
                isPresentingAlertMessage = AlertMessage(
                    title: Localized.Errors.errorOccured,
                    message: error.localizedDescription
                )
                buttonState = .normal
            }
        }
    }
}
