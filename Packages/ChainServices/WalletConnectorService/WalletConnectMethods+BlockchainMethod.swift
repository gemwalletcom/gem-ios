// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

extension WalletConnectionMethods {
    var blockchainMethod: BlockchainMethod? {
        switch self {
        // Ethereum methods
        case .ethChainId: .ethereum(.chainId)
        case .ethSign: .ethereum(.sign)
        case .personalSign: .ethereum(.personalSign)
        case .ethSignTypedData: .ethereum(.signTypedData)
        case .ethSignTypedDataV4: .ethereum(.signTypedDataV4)
        case .ethSignTransaction: .ethereum(.signTransaction)
        case .ethSendTransaction: .ethereum(.sendTransaction)
        case .ethSendRawTransaction: .ethereum(.sendRawTransaction)
        case .walletSwitchEthereumChain: .ethereum(.switchChain)
        case .walletAddEthereumChain: .ethereum(.addChain)

        // Solana methods
        case .solanaSignMessage: .solana(.signMessage)
        case .solanaSignTransaction: .solana(.signTransaction)
        case .solanaSignAndSendTransaction: .solana(.signAndSendTransaction)
        case .solanaSignAllTransactions: .solana(.signAllTransactions)

        // Sui methods
        case .suiSignPersonalMessage: .sui(.signPersonalMessage)
        case .suiSignTransaction: .sui(.signTransaction)
        case .suiSignAndExecuteTransaction: .sui(.signAndExecuteTransaction)
        }
    }
}
