import Testing
import Preferences
@testable import Support
import PreferencesTestKit

struct SupportServiceTests {

    @Test
    func getOrCreateGeneratesAndPersists() throws {
        let preferences: Preferences = .mock()
        let service = SupportService(preferences: preferences)

        let id = service.getOrCreateSupportDeviceId()

        #expect(!id.isEmpty)
        #expect(id.count == 21)
        #expect(id == id.lowercased())
        #expect(preferences.supportDeviceId == id)
        #expect(preferences.isSupportDeviceRegistered == false)
    }
}
