// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import Localization
import Style
import ContactService

struct AddContactNavigationView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var contactInput: AddContactInput? = nil
    @State private var model: AddContactViewModel
    
    init(model: AddContactViewModel) {
        _model = State(wrappedValue: model)
    }
    
    var body: some View {
        NavigationStack {
            AddContactScene(model: model)
        }
    }
}
