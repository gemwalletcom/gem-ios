// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Testing
import Primitives
import PrimitivesTestKit
import GemAPI
import GemAPITestKit
@testable import AppService

struct AppReleaseServiceTests {
    @Test
    func appReleaseServiceTests() async throws {
        let service = AppReleaseService(configService: GemAPIConfigServiceMock(config: .mock()))
        #expect(try await service.getNewestRelease()?.version == "16.1")
    }

    @Test
    func testReleaseFromConfig() async throws {
        let service = AppReleaseService(configService: GemAPIConfigServiceMock(config: .mock()))
        #expect(service.release(ConfigResponse.mock())?.version == "16.1")
    }
}
