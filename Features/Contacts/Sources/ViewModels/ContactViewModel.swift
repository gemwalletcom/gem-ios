// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import ContactService
import Localization
import Style
import Components
import PrimitivesComponents
import NameResolver
import Store

@Observable
public class ContactViewModel {
    let contactService: ContactService
    var viewType: ContactViewType
    var input: ContactInput
    let onComplete: VoidAction
    var addressesRequest: ContactAddressListRequest

    public init(
        contactService: ContactService,
        viewType: ContactViewType,
        onComplete: VoidAction
    ) {
        self.contactService = contactService
        self.viewType = viewType
        self.input = ContactInput.from(contactViewType: viewType)
        self.onComplete = onComplete
        self.addressesRequest = Self.createRequest(viewType: viewType)
    }
    
    var title: String { viewType.title }
    var actionButtonTitlte: String { Localized.Common.save }
    var nameTitleField: String { Localized.Wallet.name }
    var descriptionTitleField: String { Localized.Common.description }
    var cancelButtonTitle: String {
        switch viewType {
        case .add:
            return Localized.Common.cancel
        case .view:
            return Localized.Common.done
        }
    }
    var networksModel: NetworkSelectorViewModel {
        NetworkSelectorViewModel(state: .data(AssetConfiguration.allChains.sortByRank()))
    }
    
    func buildListItemViews(addresses: [ContactAddress]) -> [ContactListViewItem<ContactAddress>] {
        addresses
            .map {
                return ContactListViewItem<ContactAddress>(
                    id: $0.id,
                    address: $0.address,
                    memo: $0.memo?.isEmpty == false ? $0.memo : nil,
                    image: ChainImage(chain: $0.chain),
                    object: $0
                )
            }
    }

    func save() throws {
        try input.validate()
    
        let contact = try contactFromInput()
        
        switch viewType {
        case .add:
            try create(contact)
        case .view:
            try edit(contact)
        }
    }
    
    func delete(address: ContactAddress) throws {
        _ = try contactService.delete(address: address)
    }
    
    //MARK: - Private
    
    private func onCreate(with contactId: ContactId) throws {
        input.id = contactId.id
        let createdContact = try contactFromInput()
        updateViewType(viewType: .view(contact: createdContact))
    }
    
    private func contactFromInput() throws -> Contact {
        Contact(
            id: ContactId(id: input.id),
            name: try input.name.unwrappedValue,
            description: input.description.value
        )
    }
    
    private func updateViewType(viewType: ContactViewType) {
        self.viewType = viewType
        self.addressesRequest = Self.createRequest(viewType: viewType)
    }
    
    private func edit(_ contact: Contact) throws {
        try contactService.edit(contact: contact)
    }
    
    private func create(_ contact: Contact) throws {
        let contactId = try contactService.add(contact: contact)
        try onCreate(with: contactId)
    }
        
    private static func createRequest(viewType: ContactViewType) -> ContactAddressListRequest {
        switch viewType {
        case .view(let contact):
            return ContactAddressListRequest(contact: contact)
        default:
            return ContactAddressListRequest(contact: nil)
        }

    }
}
