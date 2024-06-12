// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

public struct EIP712Domain: Codable {
    public let name: String
    public let version: String
    public let chainId: Int
    public let verifyingContract: String
}

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

public let LidoDomain = EIP712Domain(
    name: "Liquid staked Ether 2.0",
    version: "2",
    chainId: 1,
    verifyingContract: LidoContract.address
)

public struct EIP712Type: Codable {
    public let name: String
    public let type: String
}

public struct ERC2612PermitMessage: Codable {
    public struct Permit: Codable {
        public let owner: String
        public let spender: String
        public let value: String
        public let nonce: String
        public let deadline: String

        public init(owner: String, spender: String, value: String, nonce: String, deadline: String) {
            self.owner = owner
            self.spender = spender
            self.value = value
            self.nonce = nonce
            self.deadline = deadline
        }
    }

    public struct Types: Codable {
        public let eip712Domain: [EIP712Type]
        public let permit: [EIP712Type]

        enum CodingKeys: String, CodingKey {
            case eip712Domain = "EIP712Domain"
            case permit = "Permit"
        }
    }

    public let types: Types
    public let primaryType: String
    public let domain: EIP712Domain
    public let message: Permit

    public init(message: Permit) {
        self.types = Types(
            eip712Domain: EIP712DomainTypes,
            permit: PermitTypes
        )
        self.primaryType = "Permit"
        self.domain = LidoDomain
        self.message = message
    }
}
