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
public class ContactAddressViewModel {
    let contactService: ContactService
    let contact: Contact
    let onComplete: VoidAction
    var networksModel: NetworkSelectorViewModel
    var nameResolveState: NameRecordState = .none
    var input: ContactAddressInput
    var viewType: ContactAddressViewType

    public init(
        contactService: ContactService,
        viewType: ContactAddressViewType,
        onComplete: VoidAction
    ) {
        self.contactService = contactService
        self.viewType = viewType
        self.onComplete = onComplete
        self.contact = viewType.contact
        self.input = ContactAddressInput.from(viewType: viewType)
        
        networksModel = NetworkSelectorViewModel(state: .data(AssetConfiguration.allChains.sortByRank()))
    }
    
    var title: String { viewType.title }
    var actionButtonTitle: String { Localized.Common.save }
    var addressTextFieldTitle: String { "Address" }
    var memoTextFieldTitle: String { "Memo" }
    var showMemo: Bool { input.chain.value?.isMemoSupported == true }
    
    func save() throws {
        try input.validate(shouldValidateAddress: nameResolveState.result == nil)
        
        let address = ContactAddress(
            id: input.id,
            contact: contact,
            address: try input.address.unwrappedValue,
            chain: try input.chain.unwrappedValue,
            memo: input.memo.value
        )
        
        switch viewType {
        case .edit:
            try contactService.edit(address: address)
        case .add:
            try contactService.add(address: address)
        }
                
        onComplete?()
    }
}
