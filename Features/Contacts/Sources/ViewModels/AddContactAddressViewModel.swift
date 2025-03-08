// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import ContactService
import Localization
import Style
import Components
import PrimitivesComponents
import NameResolver

@Observable
public class AddContactAddressViewModel: EntityEditorViewModel {
    let contactService: ContactService
    let contact: Contact
    let onComplete: VoidAction
    var networksModel: NetworkSelectorViewModel
    var input: AddContactAddressInput
    var isPresentingScanner: Bool = false
    var nameResolveState: NameRecordState = .none
    var state: StateViewType<Void> = .loaded(())

    var title: String { entityEditorViewType.title(objectName: "Address") }
    var actionButtonTitle: String { "Save" }
    var addressTextFieldTitle: String { "Address" }
    var memoTextFieldTitle: String { "Memo" }
    
    public init(
        input: AddContactAddressInput,
        contact: Contact,
        contactService: ContactService,
        entityEditorViewType: EntityEditorViewType,
        onComplete: VoidAction
    ) {
        self.contactService = contactService
        self.input = input
        self.contact = contact
        self.onComplete = onComplete
        
        networksModel = NetworkSelectorViewModel(items: AssetConfiguration.allChains.sortByRank())
        
        super.init(entityEditorViewType: entityEditorViewType)
    }
    
    func confirmAddContact() throws {
        _ = try input.validate(shouldValidateAddress: nameResolveState.result == nil)
        
        guard let chain = input.chain.value else {
            throw ValidationError.dataNotValid(description: "Please select a chain")
        }
        
        let address = ContactAddress(
            id: ContactAddressId(id: input.id),
            contactId: contact.id,
            value: input.address.value,
            chain: chain,
            memo: input.memo.value
        )
        
        switch entityEditorViewType {
        case .create:
            try contactService.add(address: address)
        case .update:
            try contactService.edit(address: address)
        }
        
        onComplete?()
    }
}
