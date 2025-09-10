// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Testing
import PriceAlertServiceTestKit
import StoreTestKit
import DeviceServiceTestKit
import GemAPITestKit
import Primitives
import PrimitivesTestKit
import Store

@testable import PriceAlertService

struct PriceAlertServiceTests {
    @Test
    func updateExistingAlertsWithChanges() async throws {
        let newDate = Date(timeIntervalSince1970: 2000)
        let localAlert = PriceAlert.mock(assetId: .mock(.bitcoin), lastNotifiedAt: nil)
        let remoteAlert = PriceAlert.mock(assetId: .mock(.bitcoin), lastNotifiedAt: newDate)

        #expect(try await performUpdate(localAlerts: [localAlert], remoteAlerts: [remoteAlert]).first?.lastNotifiedAt == newDate)
    }
    
    @Test
    func addNewAlertsFromRemote() async throws {
        let localAlert = PriceAlert.mock(assetId: .mock(.bitcoin))
        let newAlert = PriceAlert.mock(assetId: .mock(.ethereum))
        
        let savedAlerts = try await performUpdate(localAlerts: [localAlert], remoteAlerts: [localAlert, newAlert])
        
        #expect(savedAlerts.count == 2)
        #expect(savedAlerts.contains(where: { $0.assetId.chain == .bitcoin }))
        #expect(savedAlerts.contains(where: { $0.assetId.chain == .ethereum }))
    }
    
    @Test
    func removeDeletedAlertsFromLocal() async throws {
        let keepAlert = PriceAlert.mock(assetId: .mock(.bitcoin))
        let deleteAlert = PriceAlert.mock(assetId: .mock(.ethereum))

        #expect(try await performUpdate(localAlerts: [keepAlert, deleteAlert], remoteAlerts: [keepAlert]).first?.assetId.chain == .bitcoin)
    }
    
    // MARK: - Private methods
    
    private func createStore(with alerts: [PriceAlert] = []) throws -> PriceAlertStore {
        let db = DB.mockAssets()
        let store = PriceAlertStore.mock(db: db)
        try store.addPriceAlerts(alerts)
        return store
    }
    
    private func performUpdate(localAlerts: [PriceAlert], remoteAlerts: [PriceAlert]) async throws -> [PriceAlert] {
        let store = try createStore(with: localAlerts)
        let apiService = GemAPIPriceAlertServiceMock(priceAlerts: remoteAlerts)
        let service = PriceAlertService.mock(store: store, apiService: apiService)
        
        try await service.update()
        
        return try store.getPriceAlerts()
    }
}
