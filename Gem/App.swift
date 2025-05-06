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

@main
struct GemApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    private let resolver: AppResolver = AppResolver()
    
    init() {
        UNUserNotificationCenter.current().delegate = appDelegate
    }
    
    var body: some Scene {
        WindowGroup {
            RootScene(
                model: RootSceneViewModel(
                    walletConnectorPresenter: resolver.services.walletConnectorManager.presenter,
                    onstartService: resolver.services.onstartService,
                    transactionService: resolver.services.transactionService,
                    connectionsService: resolver.services.connectionsService,
                    deviceObserverService: resolver.services.deviceObserverService,
                    notificationService: resolver.services.notificationService,
                    lockWindowManager: LockWindowManager(lockModel: LockSceneViewModel()),
                    walletService: resolver.services.walletService,
                    walletsService: resolver.services.walletsService
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
            NSLog("documentsDirectory \(documentsDirectory)")
            NSLog("supportDirectory \(supportDirectory)")
            #endif
        } catch {
            NSLog("addSkipBackupAttributeToItemAtURL error \(error)")
        }

        let service = OnstartService(
            assetsService: AssetsService(
                assetStore: .main,
                balanceStore: .main,
                chainServiceFactory: .init(nodeProvider: NodeService.main)
            ),
            assetStore: .main,
            nodeStore: NodeStore.main,
            preferences: Preferences.standard,
            walletService: WalletService.main
        )
        service.migrations()
        
        Preferences.standard.incrementLaunchesCount()

        let device = UIDevice.current
        if !device.isSimulator && (device.isJailBroken || device.isFridaDetected) {
            fatalError()
        }

        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        
        Task {
            let _ = try SecurePreferences().set(value: token, key: .deviceToken)
            try await DeviceService(deviceProvider: GemAPIService.shared, subscriptionsService: .main).update()
        }
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: any Error) {
        NSLog("didFailToRegisterForRemoteNotificationsWithError error: \(error)")
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        NotificationService.main.handleUserInfo(userInfo)
    }

    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        NSLog("url \(url)")
        return true
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        //NSLog("URLContexts.first?.url \(URLContexts.first?.url)")
    }
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        //NSLog("URLContexts.first?.url \(connectionOptions.urlContexts.first?.url)")
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
        NotificationService.main.handleUserInfo(response.notification.request.content.userInfo)
        completionHandler()
    }
}
