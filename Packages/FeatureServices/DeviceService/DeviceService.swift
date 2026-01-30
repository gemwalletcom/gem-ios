// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GemAPI
import Primitives
import Store
import UIKit
import Preferences

public struct DeviceService: DeviceServiceable {

    private let deviceProvider: any GemAPIDeviceService
    private let subscriptionsService: SubscriptionService
    private let preferences: Preferences
    private let securePreferences: SecurePreferences
    private static let serialExecutor = SerialExecutor()
    
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
    
    @discardableResult
    private static func getOrCreateDeviceId(securePreferences: SecurePreferences) throws -> String {
        if let deviceId = try securePreferences.get(key: .deviceId) {
            return deviceId
        }
        return try securePreferences.set(value: generateDeviceId(), key: .deviceId)
    }

    private static func generateDeviceId() -> String {
        String(NSUUID().uuidString.replacingOccurrences(of: "-", with: "").prefix(32).lowercased())
    }

    @discardableResult
    public static func getOrCreateKeyPair(securePreferences: SecurePreferences) throws -> (privateKey: Data, publicKey: Data) {
        if let privateKey = try securePreferences.getData(key: .devicePrivateKey),
           let publicKey = try securePreferences.getData(key: .devicePublicKey) {
            return (privateKey, publicKey)
        }
        let keyPair = DeviceKeyPair()
        let publicKey = try securePreferences.set(value: keyPair.publicKey, key: .devicePublicKey)
        let privateKey = try securePreferences.set(value: keyPair.privateKey, key: .devicePrivateKey)
        return (privateKey, publicKey)
    }

    public func update() async throws  {
        try await Self.serialExecutor.execute {
            try await updateDevice()
        }
    }
    
    private func updateDevice() async throws {
        let deviceId = try self.getOrCreateDeviceId()
        let device = try await self.getOrCreateDevice(deviceId)
        let localDevice = try await self.currentDevice(deviceId: deviceId)
        if device.subscriptionsVersion != localDevice.subscriptionsVersion || self.preferences.subscriptionsVersionHasChange {
            try await self.subscriptionsService.update(deviceId: deviceId)
        }
        if device != localDevice  {
            try await self.updateDevice(localDevice)
        }
    }
    
    private func getOrCreateDevice(_ deviceId: String) async throws -> Device {
        if preferences.isDeviceRegistered {
            if let device = try await getDevice(deviceId: deviceId) {
                return device
            }
            preferences.isDeviceRegistered = false
            return try await getOrCreateDevice(deviceId)
        }
        let isRegistered = try await deviceProvider.isDeviceRegistered(deviceId: deviceId)
        if isRegistered {
            preferences.isDeviceRegistered = true
            if let device = try await getDevice(deviceId: deviceId) {
                return device
            }
        }
        let device = try await currentDevice(deviceId: deviceId, ignoreSubscriptionsVersion: true)
        let result = try await addDevice(device)
        preferences.isDeviceRegistered = true
        return result
    }
    
    public func getDeviceId() throws -> String {
        try securePreferences.getDeviceId()
    }
    
    public func getSubscriptionsDeviceId() async throws -> String {
        if preferences.subscriptionsVersionHasChange {
            try await update()
        }
        return try getDeviceId()
    }
    
    private func getOrCreateDeviceId() throws -> String {
        try Self.getOrCreateDeviceId(securePreferences: securePreferences)
    }

    @discardableResult
    private func getOrCreateKeyPair() throws -> (privateKey: Data, publicKey: Data) {
        try Self.getOrCreateKeyPair(securePreferences: securePreferences)
    }

    private func devicePublicKey() -> String? {
        try? getOrCreateKeyPair().publicKey.hex
    }
    
    @MainActor
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
            os: UIDevice.current.osName,
            model: UIDevice.current.modelName,
            token: deviceToken,
            locale: locale,
            version: Bundle.main.releaseVersionNumber,
            currency: preferences.currency,
            isPushEnabled: preferences.isPushNotificationsEnabled,
            isPriceAlertsEnabled: preferences.isPriceAlertsEnabled,
            subscriptionsVersion: ignoreSubscriptionsVersion ? 0 : preferences.subscriptionsVersion.asInt32,
            publicKey: devicePublicKey()
        )
    }
    
    private func getDevice(deviceId: String) async throws -> Device? {
        try await deviceProvider.getDevice(deviceId: deviceId)
    }
    
    @discardableResult
    private func updateDeviceId(_ deviceId: String) async throws -> Device   {
        let device = try await currentDevice(deviceId: deviceId)
        return try await updateDevice(device)
    }
    
    @discardableResult
    private func addDevice(_ device: Device) async throws -> Device {
        try await deviceProvider.addDevice(device: device)
    }

    @discardableResult
    private func updateDevice(_ device: Device) async throws -> Device {
        try await deviceProvider.updateDevice(device: device)
    }
}
