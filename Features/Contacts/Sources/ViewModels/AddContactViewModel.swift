// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import ContactService
import Localization
import Style
import Components
import PrimitivesComponents

@Observable
public class AddContactViewModel: EntityEditorViewModel {
    let contactService: ContactService
    var input: AddContactInput
    let onComplete: VoidAction

    public init(
        input: AddContactInput,
        contactService: ContactService,
        entityEditorViewType: EntityEditorViewType,
        onComplete: VoidAction
    ) {
        self.contactService = contactService
        self.input = input
        self.onComplete = onComplete
        
        super.init(entityEditorViewType: entityEditorViewType)
    }
    
    var title: String { entityEditorViewType.title(objectName: "Contact") }
    var actionButtonTitlte: String { "Save" }
    var nameTitleField: String { "Name" }
    var descriptionTitleField: String { "Description" }
        
    func addContact() throws {
        try input.validate()
        
        let contact = Contact(
            id: ContactId(id: input.id),
            name: input.name.value,
            description: input.description.value
        )
        
        switch entityEditorViewType {
        case .create:
            try contactService.add(contact: contact)
        case .update:
            try contactService.edit(contact: contact)
        }
        
        onComplete?()
    }
}
