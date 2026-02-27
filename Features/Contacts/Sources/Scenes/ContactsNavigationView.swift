// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import Components
import ContactService
import Style

public struct ContactsNavigationView: View {

    @State private var model: ContactsViewModel
    @Binding private var navigationPath: NavigationPath

    public init(
        model: ContactsViewModel,
        navigationPath: Binding<NavigationPath>
    ) {
        _model = State(initialValue: model)
        _navigationPath = navigationPath
    }

    public var body: some View {
        ContactsScene(model: model)
            .bindQuery(model.query)
            .navigationTitle(model.title)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("", systemImage: SystemImage.plus, action: {
                        model.isPresentingAddContact = true
                    })
                }
            }
            .sheet(isPresented: $model.isPresentingAddContact) {
                NavigationStack {
                    manageContact(for: .add)
                        .toolbarDismissItem(type: .close, placement: .cancellationAction)
                }
            }
            .navigationDestination(for: Scenes.Contact.self) {
                manageContact(for: .edit($0.contact))
            }
    }
    
    @ViewBuilder
    func manageContact(for mode: ManageContactViewModel.Mode) -> some View {
        ManageContactScene(
            model: ManageContactViewModel(
                service: model.service,
                nameService: model.nameService,
                mode: mode
            )
        )
    }
}
