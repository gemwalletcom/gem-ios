import XCTest
@testable import Support
import PreferencesTestKit

final class SupportServiceTests: XCTestCase {

    func testGetOrCreateGeneratesAndPersists() throws {
        let preferences = Preferences.mock()
        let service = SupportService(preferences: prefs)

        let id = service.getOrCreateSupportDeviceId()

        XCTAssertFalse(id.isEmpty)
        XCTAssertEqual(id.count, 21)
        XCTAssertEqual(id, id.lowercased())
        XCTAssertEqual(prefs.supportDeviceId, id)
        XCTAssertEqual(prefs.isSupportDeviceRegistered, false)
    }
}
