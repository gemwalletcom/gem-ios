import Testing
import StoreTestKit
import PreferencesTestKit
import AssetsServiceTestKit
import DeviceServiceTestKit
import BannerServiceTestKit
import GemAPITestKit
import ChainServiceTestKit

@testable import AppService

struct OnstartAsyncServiceTests {

    @Test
    func testNewRelease() async throws {
        let service = OnstartAsyncService.mock()
        
        await confirmation(expectedCount: 1) { @MainActor confirmation in
            service.releaseAction = { @MainActor release in
                #expect(release.version == "16.1")
                confirmation()
            }
            await service.migrations()
        }
    }
    
    @Test
    func testSkipRelease() async throws {
        let service = OnstartAsyncService.mock()
        
        await confirmation(expectedCount: 0) { @MainActor confirmation in
            service.releaseAction = { @MainActor _ in
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
            configService: GemAPIConfigServiceMock(config: .mock()),
            releaseService: AppReleaseService(configService: GemAPIConfigServiceMock(config: .mock())),
            addressStatusService: .mock()
        )
    }
}
