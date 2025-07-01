// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import DeviceServiceTestKit

@testable import DeviceService

struct DeviceSyncManagerTests {

    @Test
    func testInitialStateDoesNotTriggerUpdate() async throws {
        let deviceService = DeviceServiceMock()
        let syncManager = DeviceSyncManager(deviceService: deviceService)
        try await syncManager.ensureSynced()

        #expect(await deviceService.updateCallCount == 0)
    }

    @Test
    func testUpdateIsTriggeredWhenNeeded() async throws {
        let deviceService = DeviceServiceMock()
        let syncManager = DeviceSyncManager(deviceService: deviceService)

        await syncManager.setNeedsUpdate()
        try await syncManager.ensureSynced()

        #expect(await deviceService.updateCallCount == 1)
        
        await syncManager.setNeedsUpdate()
        try await syncManager.ensureSynced()

        #expect(await deviceService.updateCallCount == 2)
    }

    @Test
    func testConcurrentCallsTriggerOnlyOneUpdate() async throws {
        let deviceService = DeviceServiceMock()
        let syncManager = DeviceSyncManager(deviceService: deviceService)
        await syncManager.setNeedsUpdate()

        await withTaskGroup(of: Void.self) { group in
            for _ in 0..<20 {
                group.addTask {
                    try? await syncManager.ensureSynced()
                }
            }
        }

        #expect(await deviceService.updateCallCount == 1)
    }
}
