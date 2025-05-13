// Copyright (c). Gem Wallet. All rights reserved.

import Testing
@testable import Primitives
import BigInt

final class AssetRateFormatterTests {
    
    @Test func testRate() {
        let formatter = AssetRateFormatter()
        let fromAsset = Asset.mock()
        let toAsset = Asset.mockEthereumUSDT()
        
        #expect(throws: Never.self) {
            let amount = try formatter.rate(fromAsset: fromAsset, toAsset: toAsset, fromValue: BigInt(100), toValue: BigInt(100))
            #expect(amount == "1 BTC ≈ 100.00 USDT")
        }
        
        #expect(throws: Never.self) {
            let amount = try formatter.rate(fromAsset: fromAsset, toAsset: toAsset, fromValue: BigInt(131231200), toValue: BigInt(1100))
            #expect(amount == "1 BTC ≈ 0.0008382 USDT")
        }
        
        #expect(throws: Never.self) {
            let amount = try formatter.rate(fromAsset: toAsset, toAsset: fromAsset, fromValue: BigInt(100), toValue: BigInt(100))
            #expect(amount == "1 USDT ≈ 0.01 BTC")
        }
        
        #expect(throws: Never.self) {
            let amount = try formatter.rate(
                fromAsset: .mockEthereum(),
                toAsset: .mockBNB(),
                fromValue: BigInt(1000000000000000000),
                toValue: BigInt(997365015742592220)
            )
            #expect(amount == "1 ETH ≈ 1.00 BNB")
        }
    }
}
