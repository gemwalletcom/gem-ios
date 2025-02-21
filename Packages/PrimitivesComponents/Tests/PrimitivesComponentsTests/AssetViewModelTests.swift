import Testing
import Primitives
import PrimitivesTestKit

@testable import PrimitivesComponents

struct AssetViewModelTests {
    let cosmos = Asset.mock(id: Chain.cosmos.assetId, name: "Cosmos", symbol: "Atom", decimals: 8, type: .native)
    let btc = Asset.mock()

    @Test
    func testTitle() {
        #expect(AssetViewModel(asset: btc).title == "Bitcoin (BTC)")
    }
}
