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
        let signer = Signer(wallet: .mock(), keystore: LocalKeystore.mock()).signer(for: .ethereum)
        
        #expect(type(of: signer) == EthereumSigner.self)
    }
}
