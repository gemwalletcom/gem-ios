// Copyright (c). Gem Wallet. All rights reserved.

import Testing
@testable import WalletConnectorService
import Primitives
import PrimitivesTestKit
import WalletConnectSign
import WalletConnectorServiceTestKit

struct EthereumWalletConnectorServiceTests {
    let service = EthereumWalletConnectorService(signer: WalletConnectorSignableMock())

    @Test
    func signMessage() async throws {
        let signMessageMethods: [EthereumMethods] = [.sign, .personalSign, .signTypedData, .signTypedDataV4]

        for method in signMessageMethods {
            let value = try await service.handle(method: method, chain: .ethereum, request: try .mock(params: AnyCodable(["0x", "0x", "0x"]))).value as? AnyCodable
            
            #expect(value == AnyCodable("mock_signature"))
        }
    }

    @Test
    func signTransaction() async throws {
        #expect(try await service.handle(method: .signTransaction, chain: .ethereum, request: try .mock(params: WCEthereumTransaction.paramsMock())).value as? AnyCodable == AnyCodable("mock_signTransaction"))
    }

    @Test
    func sendTransaction() async throws {
        #expect(try await service.handle(method: .sendTransaction, chain: .ethereum, request: try .mock(params: WCEthereumTransaction.paramsMock())).value as? AnyCodable == AnyCodable("mock_sendTransaction"))
    }
}

extension WCEthereumTransaction {
    static func paramsMock() -> AnyCodable {
        AnyCodable([WCEthereumTransaction.mock()])
    }
}
