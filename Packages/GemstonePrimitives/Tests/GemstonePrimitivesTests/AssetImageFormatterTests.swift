// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Primitives

@testable import GemstonePrimitives

final class AssetImageFormatterTests {
    @Test
    func testGetURL() {
        let formatter = AssetImageFormatter()
        #expect(formatter.getURL(for: AssetId(chain: .ethereum, tokenId: .none))?.absoluteString == "https://assets.gemwallet.com/blockchains/ethereum/logo.png")
        #expect(formatter.getURL(for: AssetId(chain: .ethereum, tokenId: "0xdAC17F958D2ee523a2206206994597C13D831ec7"))?.absoluteString == "https://assets.gemwallet.com/blockchains/ethereum/assets/0xdAC17F958D2ee523a2206206994597C13D831ec7/logo.png")
        #expect(formatter.getURL(for: AssetId(chain: .ton, tokenId: "ton_EQAvlWFDxGF2lXm67y4yzC17wYKD9A0guwPkMs1gOsM__NOT"))?.absoluteString == "https://assets.gemwallet.com/blockchains/ton/assets/ton_EQAvlWFDxGF2lXm67y4yzC17wYKD9A0guwPkMs1gOsM__NOT/logo.png")
    }
}
