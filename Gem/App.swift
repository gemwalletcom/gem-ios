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
                    onstartAsyncService: resolver.services.onstartAsyncService,
                    onstartWalletService: resolver.services.onstartWalletService,
                    transactionService: resolver.services.transactionService,
                    connectionsService: resolver.services.connectionsService,
                    deviceObserverService: resolver.services.deviceObserverService,
                    notificationHandler: resolver.services.notificationHandler,
                    lockWindowManager: LockWindowManager(lockModel: LockSceneViewModel()),
                    walletService: resolver.services.walletService,
                    walletsService: resolver.services.walletsService,
                    nameService: resolver.services.nameService
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
        
        URLCache.shared.memoryCapacity = 256_000_000 // ~256 MB memory space
        URLCache.shared.diskCapacity = 1_000_000_000 // ~1GB disk cache space
        
        do {
            let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            let supportDirectory = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true)[0]
            
            try FileManager().addSkipBackupAttributeToItemAtURL(URL(fileURLWithPath: documentsDirectory))
            try FileManager().addSkipBackupAttributeToItemAtURL(URL(fileURLWithPath: supportDirectory))
            
            #if DEBUG
            debugLog("documentsDirectory \(documentsDirectory)")
            debugLog("supportDirectory \(supportDirectory)")
            #endif
        } catch {
            debugLog("addSkipBackupAttributeToItemAtURL error \(error)")
        }
        AppResolver.main.services.onstartService.migrations()
        AppResolver.main.storages.observablePreferences.preferences.incrementLaunchesCount()

        #if DEBUG
        // when running screenshots, set local currency
        if ProcessInfo.processInfo.environment["SCREENSHOTS_PATH"] != nil {
            if let currency = Locale.current.currency {
                Preferences.standard.currency = currency.identifier
            }
        }
        #endif
        
        let device = UIDevice.current
        if !device.isSimulator && (device.isJailBroken || device.isFridaDetected) {
            fatalError()
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
