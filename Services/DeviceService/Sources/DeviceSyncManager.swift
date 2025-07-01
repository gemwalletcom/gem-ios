// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public actor DeviceSyncManager: Sendable {

    private enum SyncState {
        case synced
        case needsSync
        case syncing(Task<Void, Error>)
    }

    private var state: SyncState = .synced
    private let deviceService: DeviceServiceable

    public init(deviceService: DeviceServiceable) {
        self.deviceService = deviceService
    }

    public func setNeedsUpdate() {
        if case .syncing = state { return }
        state = .needsSync
    }

    public func ensureSynced() async throws {
        let task: Task<Void, Error>

        switch state {
        case .synced:
            return
        case .needsSync:
            let syncTask = Task { try await deviceService.update() }
            state = .syncing(syncTask)
            task = syncTask
        case .syncing(let syncingTask):
            task = syncingTask
        }

        do {
            try await task.value
            state = .synced
        } catch {
            state = .needsSync
            throw error
        }
    }
}
