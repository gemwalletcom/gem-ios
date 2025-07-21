// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

enum EthereumMethods: String, CaseIterable, Codable, Sendable {
    case chainId = "eth_chainId"
    case sign = "eth_sign"
    case personalSign = "personal_sign"
    case signTypedData = "eth_signTypedData"
    case signTypedDataV4 = "eth_signTypedData_v4"
    case signTransaction = "eth_signTransaction"
    case sendTransaction = "eth_sendTransaction"
    case sendRawTransaction = "eth_sendRawTransaction"
    case switchChain = "wallet_switchEthereumChain"
    case addChain = "wallet_addEthereumChain"
}
