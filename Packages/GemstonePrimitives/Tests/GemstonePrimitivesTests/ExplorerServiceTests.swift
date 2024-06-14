// Copyright (c). Gem Wallet. All rights reserved.

import XCTest
@testable import GemstonePrimitives
import Gemstone
import PrimitivesTestKit
import Primitives

final class ExplorerServiceTests: XCTestCase {

    func testExplorerService() throws {
        let service = ExplorerService(storage: MockExplorerStorage())
        let chain = Chain.bitcoin
        let hash = "f9c7f0f5d34ad038cdb097902ea66a53f53bd34709569fd9a02b761288470ee2"
        XCTAssertEqual(service.transactionUrl(chain: chain, hash: hash).name, "Blockchair")
        XCTAssertEqual(service.transactionUrl(chain: chain, hash: hash).link, "https://blockchair.com/bitcoin/transaction/\(hash)")
        //TODO:
        //XCTAssertEqual(service.transactionUrl(chain: .bitcoin, hash: hash).link, "https://blockchair.com/bitcoin/transaction/\(hash)?from=gemwallet")
        
        service.set(chain: chain, name: "Mempool")
        
        XCTAssertEqual(service.transactionUrl(chain: chain, hash: hash).name, "Mempool")
    }
}
