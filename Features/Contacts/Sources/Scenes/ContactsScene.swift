// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Primitives
import PrimitivesComponents
import Style
import ContactService
import Store

public struct ContactsScene: View {

    @State private var model: ContactsViewModel

    public init(model: ContactsViewModel) {
        _model = State(initialValue: model)
    }

    public var body: some View {
        List {
            ForEach(model.contacts, id: \.id) { contact in
                NavigationCustomLink(
                    with: ListItemView(model: ContactViewModel(contact: contact).listItemModel),
                    action: { model.isPresentingManageContact = contact }
                )
            }
            .onDelete(perform: model.deleteContacts)
        }
        .contentMargins(.top, .scene.top, for: .scrollContent)
        .listStyle(.insetGrouped)
        .listSectionSpacing(.compact)
        .overlay {
            if model.contacts.isEmpty {
                EmptyContentView(model: model.emptyContent)
            }
        }
        .navigationTitle(model.title)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    model.isPresentingAddContact = true
                } label: {
                    Images.System.plus
                }
            }
        }
        .sheet(isPresented: $model.isPresentingAddContact) {
            ManageContactNavigationStack(
                model: ManageContactViewModel(
                    service: model.service,
                    onComplete: model.onAddContactComplete
                )
            )
        }
        .sheet(item: $model.isPresentingManageContact) { contact in
            ManageContactNavigationStack(
                model: ManageContactViewModel(
                    service: model.service,
                    contact: contact,
                    onComplete: model.onManageContactComplete
                )
            )
        }
        .observeQuery(request: $model.request, value: $model.contacts)
    }
}
