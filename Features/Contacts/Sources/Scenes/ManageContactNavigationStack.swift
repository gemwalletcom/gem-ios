// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import Components

public struct ManageContactNavigationStack: View {

    @State private var model: ManageContactViewModel

    public init(model: ManageContactViewModel) {
        _model = State(initialValue: model)
    }

    public var body: some View {
        NavigationStack {
            ManageContactScene(model: $model)
                .toolbarDismissItem(type: .close, placement: .cancellationAction)
        }
        .sheet(isPresented: $model.isPresentingAddAddress) {
            ManageContactAddressNavigationStack(
                model: ManageContactAddressViewModel(
                    contactId: model.contactId,
                    mode: .add,
                    onComplete: model.onAddAddressComplete
                )
            )
        }
        .sheet(item: $model.isPresentingContactAddress) { address in
            ManageContactAddressNavigationStack(
                model: ManageContactAddressViewModel(
                    contactId: model.contactId,
                    mode: .edit(address),
                    onComplete: model.onManageAddressComplete
                )
            )
        }
    }
}
