import Testing
import StoreTestKit
import PreferencesTestKit
import AssetsServiceTestKit
import DeviceServiceTestKit
import BannerServiceTestKit
import GemAPITestKit

@testable import AppService

struct OnstartAsyncServiceTests {
    @Test
    @MainActor
    func testNewRelease() async throws {
        let service = OnstartAsyncService(
            assetStore: .mock(),
            nodeStore: .mock(),
            preferences: .mock(),
            assetsService: .mock(),
            deviceService: .mock(),
            bannerSetupService: .mock(),
            configService: GemAPIConfigServiceMock(config: .mock()),
            releaseVersionNumber: "1.0.0"
        )
        
        await confirmation(expectedCount: 1) { confirmation in
            service.releaseAction = { release in
                #expect(release.version == "1.1.1")
                confirmation()
            }
            await service.migrations()
        }
    }
    
    @Test
    @MainActor
    func testSkipRelease() async throws {
        let service = OnstartAsyncService(
            assetStore: .mock(),
            nodeStore: .mock(),
            preferences: .mock(),
            assetsService: .mock(),
            deviceService: .mock(),
            bannerSetupService: .mock(),
            configService: GemAPIConfigServiceMock(config: .mock()),
            releaseVersionNumber: "1.0.0"
        )
        
        await confirmation(expectedCount: 0) { confirmation in
            service.releaseAction = { _ in
                confirmation()
            }
            service.skipRelease("1.1.1")
            await service.migrations()
        }
    }
}
