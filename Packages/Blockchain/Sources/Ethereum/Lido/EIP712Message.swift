// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives

public let EIP712DomainTypes = [
    EIP712Type(name: "name", type: "string"),
    EIP712Type(name: "version", type: "string"),
    EIP712Type(name: "chainId", type: "uint256"),
    EIP712Type(name: "verifyingContract", type: "address")
]

public let PermitTypes = [
    EIP712Type(name: "owner", type: "address"),
    EIP712Type(name: "spender", type: "address"),
    EIP712Type(name: "value", type: "uint256"),
    EIP712Type(name: "nonce", type: "uint256"),
    EIP712Type(name: "deadline", type: "uint256")
]


public extension ERC2612PermitMessage {
    init(message: ERC2612Permit, chainId: UInt32) {
        self.init(
            types: ERC2612Types(
                EIP712Domain: EIP712DomainTypes,
                Permit: PermitTypes
            ),
            primaryType: "Permit",
            domain: EIP712Domain(
                name: LidoContract.eip712DomainName,
                version: LidoContract.eip712DomainVersion,
                chainId: chainId,
                verifyingContract: LidoContract.address
            ),
            message: message
        )
    }
}
