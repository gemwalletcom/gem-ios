// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import Localization
import Style
import PrimitivesComponents

public struct ContactListNavigationView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var model: ContactListViewModel
    @State private var isPresentingContactViewType: ContactViewType?
    
    public init(model: ContactListViewModel) {
        _model = State(wrappedValue: model)
    }
    
    public var body: some View {
        ContactListScene(model: model, isPresentingContactViewType: $isPresentingContactViewType)
            .navigationBarTitleDisplayMode(.inline)
            .sheet(
                item: $isPresentingContactViewType) {
                    ContactNavigationView(
                        model: ContactViewModel(
                            contactService: model.contactService,
                            viewType: $0,
                            onComplete: {
                                isPresentingContactViewType = nil
                            }
                        )
                    )
                }
    }
}
