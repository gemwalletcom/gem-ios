// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import WalletConnectorService

struct EthereumCallDecoderTests {
    let decoder = EthereumCallDecoder()
    
    @Test
    func decodeValidERC20Transfer() {
        let result = decoder.decode(data: "0xa9059cbb0000000000000000000000002df1c51e09aecf9cacb7bc98cb1742757f163df700000000000000000000000000000000000000000000000000000000005ec1d0")

        #expect(result?.method == .transfer)
        #expect(result?.recipient == "0x2Df1c51E09aECF9cacB7bc98cB1742757f163dF7")
        #expect(result?.amount == "6210000")
    }
}
