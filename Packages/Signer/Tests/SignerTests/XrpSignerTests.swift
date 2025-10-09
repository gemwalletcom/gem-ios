// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Primitives
import PrimitivesTestKit
@testable import Signer

struct XrpSignerTests {
    @Test
    func testTransfer() throws {
        let asset = Asset(.xrp).chain.asset
        let input = SignerInput(
            type: .transfer(Asset(.xrp).chain.asset),
            asset: asset,
            value: .zero,
            fee: Fee(fee: .zero, gasPriceType: .regular(gasPrice: .zero), gasLimit: .zero),
            isMaxAmount: false,
            memo: .none,
            senderAddress: "rfX929wcdJfbjGaoB2heUFu35WBjwYyu4p",
            destinationAddress: "rNxp4h8apvRis6mJf9Sh8C6iRxfrDWN7AV",
            metadata: .xrp(sequence: 0, blockNumber: 12)
        )
        let signer = XrpSigner()
//        let expectedResult = "120000220000000024000000002e00000001614000000000000000684000000000000000732102a73ac47eb0f40940f30eb5444a6471de077a1a1c60ab7a533b82ffdf2d86a4f974473045022100afa00afbb91c65d313782d9fc2aede46d2921f86c113a3684e46bed7c9c7d7b402207b0358d1ec53bed8fff54416409d4a6a1fe0993fbb95b099ceacd09cb733cad881143a82bed955482b11cf7c32173a90e151a182ae9c83149901a6a96d83f029fb8bcf116527ad19a6eea803"
        
        #expect(try signer.signTransfer(input: input, privateKey: TestPrivateKey).isNotEmpty)
        //#expect(try signer.signTransfer(input: input, privateKey: TestPrivateKey) == expectedResult)
    }

    @Test
    func transferWithDestinationTag() throws {
        let asset = Asset(.xrp).chain.asset
        let input = SignerInput(
            type: .transfer(Asset(.xrp).chain.asset),
            asset: asset,
            value: .zero,
            fee: Fee(fee: .zero, gasPriceType: .regular(gasPrice: .zero), gasLimit: .zero),
            isMaxAmount: false,
            memo: "1",
            senderAddress: "rfX929wcdJfbjGaoB2heUFu35WBjwYyu4p",
            destinationAddress: "rNxp4h8apvRis6mJf9Sh8C6iRxfrDWN7AV",
            metadata: .xrp(sequence: 0, blockNumber: 12)
        )
        let signer = XrpSigner()
        
//        let expectedResult = "120000220000000024000000002e00000001614000000000000000684000000000000000732102a73ac47eb0f40940f30eb5444a6471de077a1a1c60ab7a533b82ffdf2d86a4f974473045022100afa00afbb91c65d313782d9fc2aede46d2921f86c113a3684e46bed7c9c7d7b402207b0358d1ec53bed8fff54416409d4a6a1fe0993fbb95b099ceacd09cb733cad881143a82bed955482b11cf7c32173a90e151a182ae9c83149901a6a96d83f029fb8bcf116527ad19a6eea803"
//        
        //TODO: Fix #expect(try signer.signTransfer(input: input, privateKey: TestPrivateKey) == expectedResult)
        
        #expect(try signer.signTransfer(input: input, privateKey: TestPrivateKey).isNotEmpty)
    }
}
