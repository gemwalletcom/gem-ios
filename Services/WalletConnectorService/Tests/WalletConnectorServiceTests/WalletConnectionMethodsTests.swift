// Copyright (c). Gem Wallet. All rights reserved.

import Testing
@testable import WalletConnectorService
import Primitives

struct WalletConnectionMethodsTests {
    
    @Test
    func ethereumMethodMappings() async throws {
        let expectedMappings: [(WalletConnectionMethods, EthereumMethods)] = [
            (.ethChainId, .chainId),
            (.ethSign, .sign),
            (.personalSign, .personalSign),
            (.ethSignTypedData, .signTypedData),
            (.ethSignTypedDataV4, .signTypedDataV4),
            (.ethSignTransaction, .signTransaction),
            (.ethSendTransaction, .sendTransaction),
            (.ethSendRawTransaction, .sendRawTransaction),
            (.walletSwitchEthereumChain, .switchChain),
            (.walletAddEthereumChain, .addChain)
        ]
        
        for (walletMethod, expectedEthMethod) in expectedMappings {
            guard case .ethereum(let actualEthMethod) = walletMethod.blockchainMethod else {
                #expect(Bool(false), "Method \(walletMethod) should convert to Ethereum method")
                continue
            }
            #expect(actualEthMethod == expectedEthMethod)
        }
    }
    
    @Test
    func solanaMethodMappings() async throws {
        let expectedMappings: [(WalletConnectionMethods, SolanaMethods)] = [
            (.solanaSignMessage, .signMessage),
            (.solanaSignTransaction, .signTransaction),
            (.solanaSignAndSendTransaction, .signAndSendTransaction),
            (.solanaSignAllTransactions, .signAllTransactions)
        ]
        
        for (walletMethod, expectedSolMethod) in expectedMappings {
            guard case .solana(let actualSolMethod) = walletMethod.blockchainMethod else {
                #expect(Bool(false), "Method \(walletMethod) should convert to Solana method")
                continue
            }
            #expect(actualSolMethod == expectedSolMethod)
        }
    }
}
