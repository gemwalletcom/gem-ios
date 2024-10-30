// Copyright (c). Gem Wallet. All rights reserved.

import XCTest
@testable import Signer
import Primitives

final class XrpSignerTests: XCTestCase {

    func testTransfer() {
        let asset = Asset(.xrp).chain.asset
        let input = SignerInput(
            type: .transfer(Asset(.xrp).chain.asset),
            asset: asset,
            value: .zero,
            fee: Fee(fee: .zero, gasPriceType: .regular(gasPrice: .zero), gasLimit: .zero),
            isMaxAmount: false,
            chainId: "",
            memo: .none,
            accountNumber: 0,
            sequence: 0,
            senderAddress: "raL4FVrt5j16nEYRACSf3zV9K7h3ouwvs1",
            destinationAddress: "rNxp4h8apvRis6mJf9Sh8C6iRxfrDWN7AV",
            block: SignerInputBlock(),
            token: SignerInputToken(),
            utxos: [],
            messageBytes: ""
        )
        let signer = XrpSigner()
        
        XCTAssertEqual(try signer.signTransfer(input: input, privateKey: TestPrivateKey), "12000022000000002400000000614000000000000000684000000000000000732102a73ac47eb0f40940f30eb5444a6471de077a1a1c60ab7a533b82ffdf2d86a4f97446304402206613241a86a4ff246c052f9b257372bd6e781b18d78d9d7f4b768da4dfdbc854022016dcf73462fdee6ca988c6bdee51d42108358cd6ff24bb3e881a147fe6486bc781143a82bed955482b11cf7c32173a90e151a182ae9c83149901a6a96d83f029fb8bcf116527ad19a6eea803")
    }
    
    func testTransferWithMemo() {
        let asset = Asset(.xrp).chain.asset
        let input = SignerInput(
            type: .transfer(Asset(.xrp).chain.asset),
            asset: asset,
            value: .zero,
            fee: Fee(fee: .zero, gasPriceType: .regular(gasPrice: .zero), gasLimit: .zero),
            isMaxAmount: false,
            chainId: "",
            memo: "1",
            accountNumber: 0,
            sequence: 0,
            senderAddress: "raL4FVrt5j16nEYRACSf3zV9K7h3ouwvs1",
            destinationAddress: "rNxp4h8apvRis6mJf9Sh8C6iRxfrDWN7AV",
            block: SignerInputBlock(),
            token: SignerInputToken(),
            utxos: [],
            messageBytes: ""
        )
        let signer = XrpSigner()
        
        XCTAssertEqual(try signer.signTransfer(input: input, privateKey: TestPrivateKey), "120000220000000024000000002e00000001614000000000000000684000000000000000732102a73ac47eb0f40940f30eb5444a6471de077a1a1c60ab7a533b82ffdf2d86a4f974473045022100afa00afbb91c65d313782d9fc2aede46d2921f86c113a3684e46bed7c9c7d7b402207b0358d1ec53bed8fff54416409d4a6a1fe0993fbb95b099ceacd09cb733cad881143a82bed955482b11cf7c32173a90e151a182ae9c83149901a6a96d83f029fb8bcf116527ad19a6eea803")
    }
}
