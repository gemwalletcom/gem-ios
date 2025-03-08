// Copyright (c). Gem Wallet. All rights reserved.

import Combine
import Primitives
import Foundation
import DataValidation

public struct AddContactInput: Identifiable {
    public var id: String
        
    var name: ValidatedInput<String, ContactNameValidator>
    var description: ValidatedInput<String, ContactDescriptionValidator>
    
    public var isEmpty: Bool { name.value.isEmpty && description.value.isEmpty }
    
    public init(
        id: ContactId? = nil,
        name: String = "",
        description: String = ""
    ) {
        self.id = id?.id ?? Self.createIdForNewEntity()
        
        self.name = .init(
            validator: ContactNameValidator(),
            value: name
        )
        self.description = .init(
            validator: ContactDescriptionValidator(),
            value: description
        )
    }
    
    public func validate() throws -> Bool {
        [
            try name.validate(),
            try description.validate()
        ].allSatisfy({$0})
    }
    
    static private func createIdForNewEntity() -> String {
        UUID().uuidString
    }
}
