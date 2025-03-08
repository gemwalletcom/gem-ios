// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style
import Components
import Store
import GRDBQuery
import Primitives
import PrimitivesComponents
import Localization

public struct ContactListScene: View {
    
    private var model: ContactListViewModel
    
    @Query<ContactListRequest>
    private var contacts: [Contact]
    
    @State var contactToDelete: Contact? = .none
    @State private var presentingErrorMessage: String?
    @Binding var isPresentingContactInput: AddContactInput?

    public init(
        model: ContactListViewModel,
        isPresentingContactInput: Binding<AddContactInput?>
    ) {
        self.model = model
        _isPresentingContactInput = isPresentingContactInput
        
        let request = Binding {
            model.contactRequest
        } set: { new in
            model.contactRequest = new
        }
        
        _contacts = Query(request)
    }
    
    public var body: some View {
        VStack {
            if contacts.isEmpty {
                StateEmptyView(
                    title: "Contact list is empty",
                    description: "Tap + to add the first one."
                )
            } else {
                listView
            }
        }
        .navigationTitle(model.title)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    isPresentingContactInput = model.input(from: nil)
                } label: {
                    Images.System.plus
                }
            }
        }
        .alert(
            "",
            isPresented: $presentingErrorMessage.mappedToBool(),
            actions: {},
            message: {
                Text(presentingErrorMessage ?? "")
            }
        )
        .confirmationDialog(
            Localized.Common.deleteConfirmation(contactToDelete?.name ?? ""),
            presenting: $contactToDelete,
            sensoryFeedback: .warning,
            actions: { contact in
                Button(
                    Localized.Common.delete,
                    role: .destructive,
                    action: { didTapConfirmDelete(contact: contact) }
                )
            }
        )
    }
    
    private var listView: some View {
        List {
            Section {
                ForEach(model.buildListItemViews(contacts: contacts)) { item in
                    NavigationLink(value: Scenes.ContactAddresses(contact: item.object)) {
                        ContactAddressListItemView(
                            name: item.name,
                            description: item.description
                        ).swipeActions(edge: .trailing) {
                            Button("Delete") {
                                didTapDelete(on: item.object)
                            }
                            .tint(Colors.red)
                            Button("Edit") {
                                didSelect(contact: item.object)
                            }
                            .tint(Colors.blue)
                        }
                    }
                        
                }
            }
        }
        .background(Colors.grayBackground)
    }
}

// MARK: - Actions

extension ContactListScene {
    private func didTapConfirmDelete(contact: Contact) {
        do {
            try model.delete(contact: contact)
        } catch {
            presentingErrorMessage = error.localizedDescription
        }
    }
    
    private func didTapDelete(on contact: Contact) {
        contactToDelete = contact
    }
    
    private func didSelect(contact: Contact) {
        isPresentingContactInput = model.input(from: contact)
    }
}
