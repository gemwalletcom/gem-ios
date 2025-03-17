// Copyright (c). Gem Wallet. All rights reserved.

import Combine
import Primitives
import Foundation
import DataValidation

public struct ContactAddressInput: Identifiable {
    public var id: String?
    
    var memo: ValidatedInput<String, StringLengthValidator>
    var address: ValidatedInput<String, BlockchainAddressValidator>
    private(set) var chain: ValidatedInput<Chain, ChainSelectionValidator>
    
    static func from(viewType: ContactAddressViewType) -> ContactAddressInput {
        switch viewType {
        case .add(_, let chain):
            return ContactAddressInput(
                chain: chain
            )
        case .edit(let address):
            return ContactAddressInput(
                id: address.id,
                address: address.address,
                chain: address.chain,
                memo: address.memo ?? ""
            )
        }
    }
        
    public init(
        id: String? = nil,
        address: String? = nil,
        chain: Chain,
        memo: String = ""
    ) {
        self.id = id
        self.chain = ValidatedInput(
            validator: ChainSelectionValidator(errorMessage: "Please select a chain"),
            value: chain
        )
        self.address = ValidatedInput(
            validator: BlockchainAddressValidator(
                chain: chain,
                errorMessage: "Address is invalid"
            ),
            value: address
        )
        self.memo = ValidatedInput(
            validator: StringLengthValidator(
                max: 149,
                errorMessage: "Please enter a correct memo (maximum 149 characters)"
            ),
            value: memo
        )
    }
    
    public func validate(shouldValidateAddress: Bool) throws {
        try chain.validate()
        if shouldValidateAddress { try address.validate() }
        try memo.validate()
    }
    
    public mutating func set(chain: Chain?) {
        self.chain.value = chain
        
        if let chain {
            let validator = BlockchainAddressValidator(chain: chain, errorMessage: "Address is invalid")
            
            do {
                try validator.validate(address.value)
                address = ValidatedInput(validator: validator, value: address.value)
            } catch {
                address = ValidatedInput(validator: validator, value: "")

            }
        }
    }
}
