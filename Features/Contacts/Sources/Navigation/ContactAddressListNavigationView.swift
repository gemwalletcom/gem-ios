// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import Localization
import Style
import Components
import PrimitivesComponents

public struct ContactAddressListNavigationView: View {
    
    @Environment(\.dismiss) private var dismiss
        
    @State private var model: ContactAddressListViewModel
    @State private var isPresentingContactAddressInput: AddContactAddressInput?
    
    public init(model: ContactAddressListViewModel) {
        self.model = model
    }
    
    public var body: some View {
        ContactAddressListScene(model: model, isPresentingContactAddressInput: $isPresentingContactAddressInput)
            .navigationBarTitleDisplayMode(.inline)
            .sheet(
                item: $isPresentingContactAddressInput) {
                    AddContactAddressNavigationView(
                        model: AddContactAddressViewModel(
                            input: $0,
                            contact: model.contact,
                            contactService: model.contactService,
                            entityEditorViewType: $0.isEmpty ? .create : .update,
                            onComplete: { isPresentingContactAddressInput = nil }
                        )
                    )
                }
    }
}
