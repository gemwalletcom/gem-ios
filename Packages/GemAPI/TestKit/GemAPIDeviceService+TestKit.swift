// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import GemAPI
import Primitives
import PrimitivesTestKit

public struct GemAPIDeviceServiceMock: GemAPIDeviceService {
    public init () {}
    public func getDevice() async throws -> Device? { Device.mock() }
    public func addDevice(device: Device) async throws -> Device { Device.mock() }
    public func updateDevice(device: Device) async throws -> Device { Device.mock() }
    public func isDeviceRegistered() async throws -> Bool { true }
    public func migrateDevice(request: MigrateDeviceIdRequest) async throws -> Device { Device.mock() }
    public func getDeviceToken() async throws -> DeviceToken { .init(token: "", expiresAt: 0) }
}
