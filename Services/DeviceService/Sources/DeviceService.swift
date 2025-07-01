// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GemAPI
import Primitives
import Store
import UIKit
import Preferences

public protocol DeviceServiceable: Sendable {
    func getDeviceId() throws -> String
    // returns same device ID as getDeviceId(), but making sure subscriptions has been updated.
    func getSubscriptionsDeviceId() async throws -> String
    func update() async throws
}

public struct DeviceService: DeviceServiceable {

    private let deviceProvider: any GemAPIDeviceService
    private let subscriptionsService: SubscriptionService
    private let preferences: Preferences
    private let securePreferences: SecurePreferences
    
    public init(
        deviceProvider: any GemAPIDeviceService,
        subscriptionsService: SubscriptionService,
        preferences: Preferences = .standard,
        securePreferences: SecurePreferences = SecurePreferences()
    ) {
        self.deviceProvider = deviceProvider
        self.subscriptionsService = subscriptionsService
        self.preferences = preferences
        self.securePreferences = securePreferences
    }
    
    public func update() async throws  {
        guard let deviceId = try await getOrCreateDeviceId() else { return }
        let device = try await getOrCreateDevice(deviceId)
        let localDevice = try currentDevice(deviceId: deviceId)
        if device.subscriptionsVersion != localDevice.subscriptionsVersion {
            try await subscriptionsService.update(deviceId: deviceId)
        }
        if device != localDevice  {
            try await updateDevice(localDevice)
        }
    }
    
    private func getOrCreateDevice(_ deviceId: String) async throws -> Device {
        do {
            return try await getDevice(deviceId: deviceId)
        } catch {
            // create device if for any reason to get current device
            let device = try currentDevice(deviceId: deviceId, ignoreSubscriptionsVersion: true)
            return try await addDevice(device)
        }
    }
    
    public func getDeviceId() throws -> String {
        return try securePreferences.getDeviceId()
    }
    
    public func getSubscriptionsDeviceId() async throws -> String {
        if preferences.subscriptionsVersionHasChange {
            try await update()
        }
        return try getDeviceId()
    }
    
    private func generateDeviceId() -> String {
        return String(NSUUID().uuidString.replacingOccurrences(of: "-", with: "").prefix(32).lowercased())
    }
    
    private func getOrCreateDeviceId() async throws -> String?  {
        do {
            let deviceId = try getDeviceId()
            return deviceId
        } catch {
            let newDeviceId = generateDeviceId()
            return try securePreferences.set(value: newDeviceId, key: .deviceId)
        }
    }
    
    private func currentDevice(
        deviceId: String,
        ignoreSubscriptionsVersion: Bool = false
    ) throws -> Device {
        let deviceToken = try securePreferences.get(key: .deviceToken) ?? .empty
        let locale = Locale.current.usageLanguageIdentifier()
        #if targetEnvironment(simulator)
        let platformStore = PlatformStore.local
        #else
        let platformStore = PlatformStore.appStore
        #endif
        
        return Device(
            id: deviceId,
            platform: .ios,
            platformStore: platformStore,
            token: deviceToken,
            locale: locale,
            version: Bundle.main.releaseVersionNumber,
            currency: preferences.currency,
            isPushEnabled: preferences.isPushNotificationsEnabled,
            isPriceAlertsEnabled: preferences.isPriceAlertsEnabled,
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
}
