// Copyright (c). Gem Wallet. All rights reserved.

import Combine
import Primitives
import Foundation
import DataValidation
import PrimitivesComponents

public struct ContactInput: Identifiable {
    public var id: String?
    var name: ValidatedInput<String, StringLengthValidator>
    var description: ValidatedInput<String, StringLengthValidator>
        
    static func from(contactViewType: ContactViewType) -> ContactInput {
        switch contactViewType {
        case .add:
            ContactInput()
        case .view(let contact):
            ContactInput(
                id: contact.id.id,
                name: contact.name,
                description: contact.description
            )
        }
    }
        
    public init(
        id: String? = nil,
        name: String? = nil,
        description: String? = nil
    ) {
        self.id = id
        
        self.name = ValidatedInput(
            validator: StringLengthValidator(
                min: 1,
                max: 25,
                errorMessage: "Please enter a valid name (minimum 1, maximum 25 characters)"
            ),
            value: name
        )
        self.description = ValidatedInput(
            validator: StringLengthValidator(
                max: 50,
                errorMessage: "Please enter a valid description (maximum 50 characters)"
            ),
            value: description
        )
    }
    
    public func validate() throws {
        try name.validate()
        try description.validate()
    }
}
