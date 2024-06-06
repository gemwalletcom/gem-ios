// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GemAPI
import Primitives
import Store
import UIKit
import Combine

class DeviceService {
    
    let deviceProvider: GemAPIDeviceService
    let preferences = Preferences()
    let securePreferences = SecurePreferences()
    let subscriptionsService: SubscriptionService
    let subscriptionsObserver: SubscriptionsObserver
    let walletStore: WalletStore
    private var subscriptionsObserverAnyCancellable: AnyCancellable?

    init(
        deviceProvider: GemAPIDeviceService = GemAPIService(),
        subscriptionsService: SubscriptionService,
        walletStore: WalletStore
    ) {
        self.deviceProvider = deviceProvider
        self.subscriptionsService = subscriptionsService
        self.walletStore = walletStore
        self.subscriptionsObserver = walletStore.observer()
    }
    
    func observer() {
        // only observing wallets at the moment, need to add addresses too
        self.subscriptionsObserverAnyCancellable = subscriptionsObserver.observe().sink { update in
            self.preferences.subscriptionsVersion += 1
            
            Task {
                try await self.update()
            }
        }
    }
    
    func update() async throws  {
        guard let deviceId = try getOrCreateDeviceId() else { return }
        let device = try await getOrCreateDevice(deviceId)
        let localDevice = try currentDevice(deviceId: deviceId)
        
        if device.subscriptionsVersion != localDevice.subscriptionsVersion {
            try await subscriptionsService.update(deviceId: deviceId)
        }
        
        if device != localDevice  {
            try await updateDevice(localDevice)
        }
    }
    
    func getOrCreateDevice(_ deviceId: String) async throws -> Device {
        do {
            return try await getDevice(deviceId: deviceId)
        } catch {
            // create device if for any reason to get current device
            let device = try currentDevice(deviceId: deviceId, ignoreSubscriptionsVersion: true)
            return try await addDevice(device)
        }
    }
    
    func getDeviceId() throws -> String? {
        return try securePreferences.get(key: .deviceId)
    }
    
    private func generateDeviceId() -> String {
        return String(NSUUID().uuidString.replacingOccurrences(of: "-", with: "").prefix(32).lowercased())
    }
    
    private func getOrCreateDeviceId() throws -> String?  {
        let deviceId = try getDeviceId()
        if deviceId == nil {
            #if DEBUG
            let newDeviceId = "ios_simulator_\(UIDevice.current.model.lowercased())_\(UIDevice.current.systemVersion)"
            return try securePreferences.set(key: .deviceId, value: newDeviceId)
            #else
            let newDeviceId = generateDeviceId()
            return try securePreferences.set(key: .deviceId, value: newDeviceId)
            #endif
        }
        return try getDeviceId()
    }
    
    private func currentDevice(
        deviceId: String,
        ignoreSubscriptionsVersion: Bool = false
    ) throws -> Device {
        let deviceToken = try securePreferences.get(key: .deviceToken) ?? .empty
        let locale = Locale.current.language.languageCode?.identifier ?? .empty
        return Device(
            id: deviceId,
            platform: .ios,
            token: deviceToken,
            locale: locale,
            version: Bundle.main.releaseVersionNumber,
            currency: preferences.currency,
            isPushEnabled: preferences.isPushNotificationsEnabled,
            subscriptionsVersion: ignoreSubscriptionsVersion ? 0 : preferences.subscriptionsVersion.asInt32
        )
    }
    
    private func getDevice(deviceId: String) async throws -> Device {
        return try await deviceProvider.getDevice(deviceId: deviceId)
    }
    
    @discardableResult
    private func updateDeviceId(_ deviceId: String) async throws -> Device   {
        let device = try currentDevice(deviceId: deviceId)
        return try await updateDevice(device)
    }
    
    @discardableResult
    private func addDevice(_ device: Device) async throws -> Device {
        return try await deviceProvider.addDevice(device: device)
    }
    
    @discardableResult
    private func updateDevice(_ device: Device) async throws -> Device {
        return try await deviceProvider.updateDevice(device: device)
    }
    
    // permissions
    
    func requestPermissions() async throws -> Bool {
        let result = try await UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .sound, .alert])
        await UIApplication.shared.registerForRemoteNotifications()
        return result
    }
}
