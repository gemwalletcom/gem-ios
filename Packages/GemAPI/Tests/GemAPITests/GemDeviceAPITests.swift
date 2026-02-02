// Copyright (c). Gem Wallet. All rights reserved.

import XCTest
import Primitives
@testable import GemAPI

final class GemDeviceAPITests: XCTestCase {
    
    // MARK: - Path Tests
    
    func testDeviceEndpointsShareSamePath() {
        let deviceId = "test-device-id"
        let device = Device(
            id: deviceId,
            isPushNotificationsEnabled: false,
            platform: .ios,
            token: "test-token",
            locale: "en",
            version: "1.0",
            createdAt: .now,
            currency: "USD"
        )
        
        // All device operations should use the same base path
        XCTAssertEqual(GemDeviceAPI.addDevice(device: device).path, "/v2/devices")
        XCTAssertEqual(GemDeviceAPI.getDevice(deviceId: deviceId).path, "/v2/devices")
        XCTAssertEqual(GemDeviceAPI.deleteDevice(deviceId: deviceId).path, "/v2/devices")
        XCTAssertEqual(GemDeviceAPI.updateDevice(device: device).path, "/v2/devices")
    }
    
    func testSubscriptionEndpointsShareSamePath() {
        let deviceId = "test-device-id"
        let subscriptions = [WalletSubscription(walletIndex: 0, chain: .bitcoin)]
        let chains = [WalletSubscriptionChains(walletIndex: 0, chains: [.bitcoin])]
        
        // All subscription operations should use the same path
        XCTAssertEqual(GemDeviceAPI.getSubscriptions(deviceId: deviceId).path, "/v2/devices/subscriptions")
        XCTAssertEqual(GemDeviceAPI.addSubscriptions(deviceId: deviceId, subscriptions: subscriptions).path, "/v2/devices/subscriptions")
        XCTAssertEqual(GemDeviceAPI.deleteSubscriptions(deviceId: deviceId, subscriptions: chains).path, "/v2/devices/subscriptions")
    }
    
    func testPriceAlertsEndpointsShareSamePath() {
        let deviceId = "test-device-id"
        let assetId = AssetId(chain: .bitcoin, tokenId: nil)
        let priceAlerts = [PriceAlert(id: "1", assetId: assetId, price: 50000, priceDirection: .up)]
        
        // All price alert operations should use the same path
        XCTAssertEqual(GemDeviceAPI.getPriceAlerts(deviceId: deviceId, assetId: assetId.identifier).path, "/v2/devices/price_alerts")
        XCTAssertEqual(GemDeviceAPI.addPriceAlerts(deviceId: deviceId, priceAlerts: priceAlerts).path, "/v2/devices/price_alerts")
        XCTAssertEqual(GemDeviceAPI.deletePriceAlerts(deviceId: deviceId, priceAlerts: priceAlerts).path, "/v2/devices/price_alerts")
    }
    
    // MARK: - Data Tests
    
    func testSubscriptionOperationsReturnEncodableData() {
        let deviceId = "test-device-id"
        let subscriptions = [WalletSubscription(walletIndex: 0, chain: .bitcoin)]
        let chains = [WalletSubscriptionChains(walletIndex: 0, chains: [.bitcoin])]
        
        // Both add and delete should return encodable data
        let addData = GemDeviceAPI.addSubscriptions(deviceId: deviceId, subscriptions: subscriptions).data
        let deleteData = GemDeviceAPI.deleteSubscriptions(deviceId: deviceId, subscriptions: chains).data
        
        // Verify both are encodable type (not plain)
        if case .encodable = addData {
            XCTAssert(true)
        } else {
            XCTFail("addSubscriptions should return encodable data")
        }
        
        if case .encodable = deleteData {
            XCTAssert(true)
        } else {
            XCTFail("deleteSubscriptions should return encodable data")
        }
    }
    
    func testDeviceOperationsReturnCorrectDataType() {
        let deviceId = "test-device-id"
        let device = Device(
            id: deviceId,
            isPushNotificationsEnabled: false,
            platform: .ios,
            token: "test-token",
            locale: "en",
            version: "1.0",
            createdAt: .now,
            currency: "USD"
        )
        
        // Get and delete should return plain data
        let getData = GemDeviceAPI.getDevice(deviceId: deviceId).data
        let deleteData = GemDeviceAPI.deleteDevice(deviceId: deviceId).data
        
        if case .plain = getData {
            XCTAssert(true)
        } else {
            XCTFail("getDevice should return plain data")
        }
        
        if case .plain = deleteData {
            XCTAssert(true)
        } else {
            XCTFail("deleteDevice should return plain data")
        }
        
        // Add and update should return encodable data
        let addData = GemDeviceAPI.addDevice(device: device).data
        let updateData = GemDeviceAPI.updateDevice(device: device).data
        
        if case .encodable = addData {
            XCTAssert(true)
        } else {
            XCTFail("addDevice should return encodable data")
        }
        
        if case .encodable = updateData {
            XCTAssert(true)
        } else {
            XCTFail("updateDevice should return encodable data")
        }
    }
}
