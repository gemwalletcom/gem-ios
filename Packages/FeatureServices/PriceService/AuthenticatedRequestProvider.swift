// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Preferences
import WebSocketClient
import GemAPI
import DeviceService

struct AuthenticatedRequestProvider: WebSocketRequestProvider {
    private let securePreferences: SecurePreferences

    init(securePreferences: SecurePreferences) {
        self.securePreferences = securePreferences
    }

    func makeRequest() throws -> URLRequest {
        let deviceId = try securePreferences.getDeviceId()
        let keyPair = try DeviceService.getOrCreateKeyPair(securePreferences: securePreferences)
        let signer = try DeviceRequestSigner(privateKey: keyPair.privateKey)

        var request = URLRequest(url: Constants.deviceStreamWebSocketURL)
        request.httpMethod = "GET"
        request.setValue(deviceId, forHTTPHeaderField: "x-device-id")
        try signer.sign(request: &request)
        return request
    }
}
