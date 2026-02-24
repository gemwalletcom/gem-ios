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
            ForEach(model.contacts) { contact in
                NavigationCustomLink(
                    with: ListItemView(model: model.listItemModel(for: contact)),
                    action: { model.isPresentingContact = contact }
                )
            }
            .onDelete(perform: model.deleteContacts)
        }
        .contentMargins(.top, .scene.top, for: .scrollContent)
        .listStyle(.insetGrouped)
        .listSectionSpacing(.compact)
        .scrollContentBackground(.hidden)
        .background { Colors.insetGroupedListStyle.ignoresSafeArea() }
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
                    nameService: model.nameService,
                    mode: .add,
                    onComplete: model.onAddContactComplete
                )
            )
        }
        .sheet(item: $model.isPresentingContact) { contact in
            ManageContactNavigationStack(
                model: ManageContactViewModel(
                    service: model.service,
                    nameService: model.nameService,
                    mode: .edit(contact),
                    onComplete: model.onManageContactComplete
                )
            )
        }
        .bindQuery(model.query)
    }
}
