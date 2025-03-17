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
    @State private var isPresentingErrorMessage: String?
    @Binding var isPresentingContactViewType: ContactViewType?

    public init(
        model: ContactListViewModel,
        isPresentingContactViewType: Binding<ContactViewType?>
    ) {
        self.model = model
        _isPresentingContactViewType = isPresentingContactViewType
        
        let request = Binding {
            model.contactRequest
        } set: { new in
            model.contactRequest = new
        }
        
        _contacts = Query(request)
    }
    
    public var body: some View {
        List {
            Section {
                ForEach(model.buildListItemViews(contacts: contacts)) { item in
                    NavigationCustomLink(with: ListItemView(
                        title: item.name,
                        titleExtra: item.description
                    )) {
                        isPresentingContactViewType = .view(contact: item.object)
                    }.swipeActions(edge: .trailing) {
                        Button(Localized.Common.delete) {
                            onSelectDelete(on: item.object)
                        }
                        .tint(Colors.red)
                    }
                }
            }
        }
        .overlay {
            if contacts.isEmpty {
                ZStack {
                    Colors.insetGroupedListStyle.ignoresSafeArea()
                    Text("No contacts yet.")
                        .textStyle(.body)
                }
            }
        }
        .navigationTitle(model.title)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    isPresentingContactViewType = .add
                } label: {
                    Images.System.plus
                }
            }
        }
        .alert(
            "",
            isPresented: $isPresentingErrorMessage.mappedToBool(),
            actions: {},
            message: {
                Text(isPresentingErrorMessage ?? "")
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
                    action: { onSelectConfirmDelete(contact: contact) }
                )
            }
        )
    }
}

// MARK: - Actions

extension ContactListScene {
    private func onSelectConfirmDelete(contact: Contact) {
        do {
            try model.delete(contact: contact)
        } catch {
            isPresentingErrorMessage = error.localizedDescription
        }
    }
    
    private func onSelectDelete(on contact: Contact) {
        contactToDelete = contact
    }
}
