import SwiftUI
import Keystore
import Style
import Store
import Primitives

@main
struct GemApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @State var db = DB.main
    
    init(){
        UNUserNotificationCenter.current().delegate = appDelegate
    }
    
    var body: some Scene {
        WindowGroup {
            WalletCoordinator(
                db: db
            )
            .databaseContext(.readWrite { db.dbQueue })
            .navigationBarTitleDisplayMode(.inline)
            .tint(Colors.black)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate, UIWindowSceneDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        // set cache
        URLCache.shared.memoryCapacity = 256_000_000 // ~256 MB memory space
        URLCache.shared.diskCapacity = 1_000_000_000 // ~1GB disk cache space
        
        do {
            let directory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            try FileManager().addSkipBackupAttributeToItemAtURL(URL(fileURLWithPath: directory))
            #if DEBUG
            NSLog("directory \(directory)")
            #endif
        } catch {
            NSLog("addSkipBackupAttributeToItemAtURL error \(error)")
        }

        let keystore = LocalKeystore.main
        
        // debug
        #if DEBUG
        
        NSLog("Keystore directory: \(keystore.directory)")
        //NSLog("Keystore currentWallet: \(String(describing: keystore.currentWallet))")
        NSLog("keystore numbers of wallets: \(keystore.wallets.count)")
        
        //NSLog("User Defaults: \(UserDefaults.standard.dictionaryRepresentation())")
        
        #endif
        
        // screenshots
        if ProcessInfo().arguments.contains("SKIP_ANIMATIONS") {
            UIView.setAnimationsEnabled(false)
            // set device
            try! SecurePreferences().set(key: .deviceId, value: "screenshots")
        }
        
        let service = OnstartService(
            assetsService: AssetsService(
                assetStore: .main,
                balanceStore: .main,
                chainServiceFactory: .init(nodeProvider: NodeService.main)
            ),
            assetStore: AssetStore(db: .main),
            nodeStore: NodeStore(db: .main),
            keystore: keystore
        )
        service.migrations()
        
        PreferencesStore.main.incrementLaunchesCount()
        
        if let userInfo = launchOptions?[.remoteNotification] as? [String: AnyObject] {
            NSLog("didFinishLaunchingWithOptions userInfo \(userInfo)")
        }
        
        let device = UIDevice.current
        if !device.isSimulator && (device.isJailBroken || device.isFridaDetected) {
            fatalError()
        }
        
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        
        Task {
            let _ = try SecurePreferences().set(key: .deviceToken, value: token)
            try await DeviceService(subscriptionsService: .main, walletStore: .main).update()
        }
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        NSLog("didFailToRegisterForRemoteNotificationsWithError error: \(error)")
    }
    
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        NSLog("url \(url)")
        return true
    }
    
    func scene(_ scene: UIScene, didUpdate userActivity: NSUserActivity) {
        
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        //NSLog("URLContexts.first?.url \(URLContexts.first?.url)")
    }
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        //NSLog("URLContexts.first?.url \(connectionOptions.urlContexts.first?.url)")
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.badge, .banner, .list, .sound])
        //let userInfo = notification.request.content.userInfo
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        //let userInfo = response.notification.request.content.userInfo
    }
}
