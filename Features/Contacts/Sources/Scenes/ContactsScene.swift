// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Components
import Primitives
import PrimitivesComponents
import Style

public struct ContactsScene: View {

    let model: ContactsViewModel

    public init(model: ContactsViewModel) {
        self.model = model
    }

    public var body: some View {
        List {
            ForEach(model.contacts) { contact in
                NavigationLink(value: Scenes.Contact(contact: contact)) {
                    ListItemView(model: model.listItemModel(for: contact))
                }
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
    }
}
