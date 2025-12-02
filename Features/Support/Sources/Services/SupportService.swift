import Foundation
import Preferences
import Primitives
import GemAPI

public struct SupportService: Sendable {
    private let preferences: Preferences
    private let securePreferences: SecurePreferences
    private let api: any GemAPISupportService

    public init(
        preferences: Preferences = .standard,
        securePreferences: SecurePreferences = .standard,
        api: any GemAPISupportService = GemAPIService()
    ) {
        self.preferences = preferences
        self.securePreferences = securePreferences
        self.api = api
    }

    public func getOrCreateSupportDeviceId() -> String {
        if let id = preferences.supportDeviceId {
            return id
        }
        let newId = String(UUID().uuidString.replacingOccurrences(of: "-", with: "").lowercased().prefix(21))
        preferences.supportDeviceId = newId
        preferences.isSupportDeviceRegistered = false
        return newId
    }

    public func registerSupportDeviceIfNeeded() async throws  {
        guard preferences.isSupportDeviceRegistered == false else { return }
        let supportDevice = NewSupportDevice(
            supportDeviceId: getOrCreateSupportDeviceId(),
            deviceId: try securePreferences.getDeviceId()
        )
        let _ = try await api.addSupportDevice(supportDevice)
        preferences.isSupportDeviceRegistered = true
    }
}
