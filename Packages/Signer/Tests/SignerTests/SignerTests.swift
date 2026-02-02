// Copyright (c). Gem Wallet. All rights reserved.

import Testing
import Foundation
@testable import Signer
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
    
    @Test
    func testChainSignerForMultipleChainTypes() async throws {
        let wallet = Wallet.mock()
        let keystore = LocalKeystore.mock()
        let signer = Signer(wallet: wallet, keystore: keystore)
        
        // Test that aptos, sui, and hyperCore all return ChainSigner
        let aptosSigner = signer.signer(for: .aptos)
        let suiSigner = signer.signer(for: .sui)
        let hyperCoreSigner = signer.signer(for: .hyperCore)
        
        #expect(type(of: aptosSigner) == ChainSigner.self)
        #expect(type(of: suiSigner) == ChainSigner.self)
        #expect(type(of: hyperCoreSigner) == ChainSigner.self)
    }
}
