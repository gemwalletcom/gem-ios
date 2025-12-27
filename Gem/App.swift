// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style
import Store
import Primitives
import DeviceService
import NodeService
import GemAPI
import LockManager
import Preferences
import AssetsService
import WalletService
import AppService

@main
struct GemApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    private let resolver: AppResolver = .main
    
    init() {
        UNUserNotificationCenter.current().delegate = appDelegate
    }
    
    var body: some Scene {
        WindowGroup {
            RootScene(
                model: RootSceneViewModel(
                    walletConnectorPresenter: resolver.services.walletConnectorManager.presenter,
                    onstartWalletService: resolver.services.onstartWalletService,
                    transactionStateService: resolver.services.transactionStateService,
                    connectionsService: resolver.services.connectionsService,
                    deviceObserverService: resolver.services.deviceObserverService,
                    notificationHandler: resolver.services.notificationHandler,
                    lockWindowManager: LockWindowManager(lockModel: LockSceneViewModel()),
                    walletService: resolver.services.walletService,
                    walletsService: resolver.services.walletsService,
                    nameService: resolver.services.nameService,
                    releaseAlertService: resolver.services.releaseAlertService,
                    rateService: resolver.services.rateService,
                    eventPresenterService: resolver.services.eventPresenterService,
                    avatarService: resolver.services.avatarService
                )
            )
            .inject(resolver: resolver)
            .navigationBarTitleDisplayMode(.inline)
            .tint(Colors.black)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate, UIWindowSceneDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        AppResolver.main.services.onstartService.configure()
        Task {
            await AppResolver.main.services.onstartAsyncService.run()
        }
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        
        Task {
            let _ = try SecurePreferences.standard.set(value: token, key: .deviceToken)
            try await AppResolver.main.services.deviceService.update()
        }
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: any Error) {
        debugLog("didFailToRegisterForRemoteNotificationsWithError error: \(error)")
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        AppResolver.main.services.notificationHandler.handleUserInfo(userInfo)
    }

    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        debugLog("url \(url)")
        return true
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        //debugLog("URLContexts.first?.url \(URLContexts.first?.url)")
    }
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        //debugLog("URLContexts.first?.url \(connectionOptions.urlContexts.first?.url)")
    }

    func application(_ application: UIApplication, shouldAllowExtensionPointIdentifier extensionPointIdentifier: UIApplication.ExtensionPointIdentifier) -> Bool {
        switch extensionPointIdentifier {
        case .keyboard: false
        default: true
        }
    }
}

extension AppDelegate: @preconcurrency UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.badge, .banner, .list, .sound])
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        AppResolver.main.services.notificationHandler.handleUserInfo(response.notification.request.content.userInfo)
        completionHandler()
    }
}
