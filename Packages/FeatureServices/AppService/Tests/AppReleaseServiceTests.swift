// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Testing
import Primitives
import PrimitivesTestKit
import Store
import StoreTestKit
import AppServiceTestKit
@testable import AppService

struct AppReleaseServiceTests {
    @Test
    func newestRelease() throws {
        let configStore = ConfigStore(db: .mock())
        try configStore.update(.mock())
        let service = AppReleaseService(configService: ConfigService(configStore: configStore))

        #expect(try service.getNewestRelease()?.version == "16.1")
    }

    @Test
    func releaseFromConfig() {
        #expect(AppReleaseService(configService: .mock()).release(ConfigResponse.mock())?.version == "16.1")
    }
}
