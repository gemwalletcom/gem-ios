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
                    action: { model.onSelectContact(contact) }
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
                Button(action: model.onSelectAddContact) {
                    Images.System.plus
                }
            }
        }
        .sheet(item: $model.isPresentingContact) {
            ManageContactNavigationStack(
                model: ManageContactViewModel(
                    service: model.service,
                    mode: $0,
                    onComplete: model.onManageContactComplete
                )
            )
        }
        .bindQuery(model.query)
    }
}
