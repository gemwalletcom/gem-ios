// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Foundation
import Signer
import Keystore
import KeystoreTestKit
import PrimitivesTestKit

let TestPrivateKey = Data(hexString: "1E9D38B5274152A78DFF1A86FA464CEADC1F4238CA2C17060C3C507349424A34")!

struct SignerTests {
    
    @Test 
    func testSignMessage() async throws {
        let signer = Signer(wallet: .mock(), keystore: LocalKeystore.mock())
        
        let signature = try signer.signMessage(
            chain: .ethereum,
            message:
                    .typed(
                        "{\"domain\":{\"name\":\"Permit2\",\"chainId\":56,\"verifyingContract\":\"0x000000000022D473030F116dDEE9F6B43aC78BA3\"},\"types\":{\"EIP712Domain\":[{\"name\":\"name\",\"type\":\"string\"},{\"name\":\"chainId\",\"type\":\"uint256\"},{\"name\":\"verifyingContract\",\"type\":\"address\"}],\"PermitSingle\":[{\"name\":\"details\",\"type\":\"PermitDetails\"},{\"name\":\"spender\",\"type\":\"address\"},{\"name\":\"sigDeadline\",\"type\":\"uint256\"}],\"PermitDetails\":[{\"name\":\"token\",\"type\":\"address\"},{\"name\":\"amount\",\"type\":\"uint160\"},{\"name\":\"expiration\",\"type\":\"uint48\"},{\"name\":\"nonce\",\"type\":\"uint48\"}]},\"primaryType\":\"PermitSingle\",\"message\":{\"details\":{\"token\":\"0x76A797A59Ba2C17726896976B7B3747BfD1d220f\",\"amount\":\"1000000000\",\"expiration\":\"1731140703\",\"nonce\":\"0\"},\"spender\":\"0x4Dae2f939ACf50408e13d58534Ff8c2776d45265\",\"sigDeadline\":\"1731034503\"}}"
                    ),
            privateKey: TestPrivateKey
        )
        
        #expect(signature == "3e68cd01402049ccf974f9bd605ef921c732015bf12e5b2b053815fb443ffd1917a15ec08352d4c63a47f616f9b67ea1409797cc36d8a7d8016540573c5483081b")
    }
}