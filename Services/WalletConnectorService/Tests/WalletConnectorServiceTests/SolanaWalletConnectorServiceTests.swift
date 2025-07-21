// Copyright (c). Gem Wallet. All rights reserved.

import Testing
@testable import WalletConnectorService
import Primitives
import WalletConnectSign
import WalletConnectorServiceTestKit
import PrimitivesTestKit

struct SolanaWalletConnectorServiceTests {
    let service = SolanaWalletConnectorService(signer: WalletConnectorSignableMock())
    
    @Test
    func signMessage() async throws {
        #expect(try await service.handle(method: .signMessage, request: try .mock(chain: .solana, params: .signMessageMock())).value as? AnyCodable == .signMessageValue())
    }
    
    @Test
    func signTransaction() async throws {
        #expect(try await service.handle(method: .signTransaction, request: try .mock(chain: .solana, params: .transactionMock())).value as? AnyCodable == .signTransactionValue())
    }
    
    @Test
    func sendTransaction() async throws {
        #expect(try await service.handle(method: .signAndSendTransaction, request: try .mock(chain: .solana, params: .transactionMock())).value as? AnyCodable == .sendTransactionValue())
    }
}

extension AnyCodable {
    static func signMessageMock() -> AnyCodable {
        AnyCodable(WCSolanaSignMessage.mock())
    }
    
    static func transactionMock() -> AnyCodable {
        AnyCodable(WCSolanaTransaction.mock())
    }
    
    static func signMessageValue() -> AnyCodable {
        AnyCodable(WCSolanaSignMessageResult(signature: "mock_signature"))
    }
    
    static func signTransactionValue() -> AnyCodable {
        AnyCodable(WCSolanaSignMessageResult(signature: "mock_signTransaction"))
    }
    
    static func sendTransactionValue() -> AnyCodable {
        AnyCodable("mock_sendTransaction")
    }
}
