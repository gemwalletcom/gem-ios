// Copyright (c). Gem Wallet. All rights reserved.

import Combine
import Primitives
import Foundation
import DataValidation

public struct AddContactAddressInput: Identifiable {
    public var id: String
    
    var memo: ValidatedInput<String, ContactAddressMemoValidator>
    var address: ValidatedInput<String, BlockchainAddressValidator>
    private(set) var chain: ValidatedInput<Chain, ChainSelectionValidator>
    
    public var isEmpty: Bool { chain.value == nil && address.value.isEmpty }
    
    public init(
        id: ContactAddressId? = nil,
        address: String = "",
        chain: Chain? = nil,
        memo: String = ""
    ) {
        self.id = id?.id ?? Self.createIdForNewEntity()
        self.chain = ValidatedInput(
            validator: ChainSelectionValidator(),
            value: chain
        )
        self.address = ValidatedInput(
            validator: BlockchainAddressValidator(chain: chain),
            value: address
        )
        self.memo = ValidatedInput(
            validator: ContactAddressMemoValidator(),
            value: memo
        )
    }
    
    public func validate(shouldValidateAddress: Bool) throws -> Bool {
        [
            try chain.validate(),
            shouldValidateAddress ? try address.validate() : nil,
            try memo.validate()
        ]
            .compactMap { $0 }
            .allSatisfy({$0})
    }
    
    public mutating func set(chain: Chain?) {
        self.chain.value = chain
        
        if let chain {
            let validator = BlockchainAddressValidator(chain: chain)
            let currentAddressIsValid = (try? validator.isValid(address.value)) == true
            let addressValue = currentAddressIsValid ? address.value : ""
            address = ValidatedInput(validator: validator, value: addressValue)
        }
    }
    
    static private func createIdForNewEntity() -> String {
        UUID().uuidString
    }
}
