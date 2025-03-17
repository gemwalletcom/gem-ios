// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import Localization
import Style
import ContactService
import Components
import PrimitivesComponents
import QRScanner

struct ContactNavigationView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var isPresentingContactAddressViewType: ContactAddressViewType?
    @State private var model: ContactViewModel

    init(model: ContactViewModel) {
        _model = State(wrappedValue: model)
    }
    
    var body: some View {
        NavigationStack {
            ContactScene(
                model: model,
                isPresentingContactAddressViewType: $isPresentingContactAddressViewType
            )
            .sheet(item: $isPresentingContactAddressViewType) {
                ContactAddressNavigationView(
                    model: ContactAddressViewModel(
                        contactService: model.contactService,
                        viewType: $0,
                        onComplete: {
                        isPresentingContactAddressViewType = nil
                    })
                )
            }
            
        }
    }
}
