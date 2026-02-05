// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GemAPI
import Primitives
import PrimitivesTestKit

public struct GemAPIDeviceServiceMock: GemAPIDeviceService {
    public init () {}
    public func getDevice(deviceId: String) async throws -> Device? { Device.mock() }
    public func addDevice(device: Device) async throws -> Device { Device.mock() }
    public func updateDevice(device: Device) async throws -> Device { Device.mock() }
    public func deleteDevice(deviceId: String) async throws {}
    public func isDeviceRegistered(deviceId: String) async throws -> Bool { true }
    public func migrateDevice(request: MigrateDeviceIdRequest) async throws -> Device { Device.mock() }
}
