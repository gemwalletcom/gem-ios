import Testing
import StoreTestKit
import PreferencesTestKit
import AssetsServiceTestKit
import DeviceServiceTestKit
import BannerServiceTestKit
import GemAPITestKit

@testable import AppService

@MainActor
struct OnstartAsyncServiceTests {
    @Test
    func testNewRelease() async throws {
        let service = OnstartAsyncService.mock()
        
        await confirmation(expectedCount: 1) { @Sendable confirmation in
            service.releaseAction = { @Sendable release in
                #expect(release.version == "16.1")
                confirmation()
            }
            await service.migrations()
        }
    }
    
    @Test
    func testSkipRelease() async throws {
        let service = OnstartAsyncService.mock()
        
        await confirmation(expectedCount: 0) { @Sendable confirmation in
            service.releaseAction = { @Sendable _ in
                confirmation()
            }
            service.skipRelease("16.1")
            await service.migrations()
        }
    }
}

extension OnstartAsyncService {
    static func mock() -> OnstartAsyncService {
        OnstartAsyncService(
            assetStore: .mock(),
            nodeStore: .mock(),
            preferences: .mock(),
            assetsService: .mock(),
            deviceService: .mock(),
            bannerSetupService: .mock(),
            configService: GemAPIConfigServiceMock(config: .mock())
        )
    }
}
