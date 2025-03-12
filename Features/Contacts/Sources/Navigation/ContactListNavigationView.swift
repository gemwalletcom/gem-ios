// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import Localization
import Style

public struct ContactListNavigationView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var model: ContactListViewModel
    @State private var isPresentingContactInput: AddContactInput?
    
    public init(model: ContactListViewModel) {
        _model = State(wrappedValue: model)
    }
    
    public var body: some View {
        ContactListScene(model: model, isPresentingContactInput: $isPresentingContactInput)
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: Scenes.ContactAddresses.self) {
                ContactAddressListNavigationView(
                    model: ContactAddressListViewModel(
                        contact: $0.contact,
                        contactService: model.contactService
                    )
                )
            }
            .sheet(
                item: $isPresentingContactInput) {
                    AddContactNavigationView(
                        model: AddContactViewModel(
                            input: $0,
                            contactService: model.contactService,
                            entityEditorViewType: $0.isEmpty ? .create : .update,
                            onComplete: {
                                isPresentingContactInput = nil
                            }
                        )
                    )
                }
    }
}
