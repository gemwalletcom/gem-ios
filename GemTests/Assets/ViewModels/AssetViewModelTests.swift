import XCTest
@testable import Gem

final class AssetViewModelTests: XCTestCase {

    func testTitle() {
        XCTAssertEqual(AssetViewModel(asset: .bitcoin).title, "Bitcoin (BTC)")
    }
    
    func testSupportMemo() {
        XCTAssertTrue(AssetViewModel(asset: .cosmos).supportMemo)
        XCTAssertFalse(AssetViewModel(asset: .bitcoin).supportMemo)
    }
}
