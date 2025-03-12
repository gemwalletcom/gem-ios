// Copyright (c). Gem Wallet. All rights reserved.

import Combine
import Primitives
import Foundation
import DataValidation

public struct AddContactInput: Identifiable {
    public var id: String
        
    var name: ValidatedInput<String, StringLengthValidator>
    var description: ValidatedInput<String, StringLengthValidator>
    
    public var isEmpty: Bool { name.value.isEmpty && description.value.isEmpty }
    
    public init(
        id: ContactId? = nil,
        name: String = "",
        description: String = ""
    ) {
        self.id = id?.id ?? Self.createIdForNewEntity()
        
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
    
    static private func createIdForNewEntity() -> String {
        UUID().uuidString
    }
}
