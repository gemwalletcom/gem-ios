 //Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Style
import Components
import Store
import GRDBQuery
import PrimitivesComponents
import Primitives
import Localization

public struct ContactAddressListScene: View {
    
    private var model: ContactAddressListViewModel
    
    @Query<ContactAddressListRequest>
    private var addresses: [ContactAddress]
    
    @State var addressToDelete: ContactAddress? = .none
    @State private var presentingErrorMessage: String?
    @Binding var isPresentingContactAddressInput: AddContactAddressInput?
    
    public init(
        model: ContactAddressListViewModel,
        isPresentingContactAddressInput: Binding<AddContactAddressInput?>
    ) {
        self.model = model
        _isPresentingContactAddressInput = isPresentingContactAddressInput
        
        let request = Binding {
            model.addressListRequest
        } set: { new in
            model.addressListRequest = new
        }
        
        _addresses = Query(request)
    }
    
    public var body: some View {
        VStack {
            if addresses.isEmpty {
                StateEmptyView(
                    title: "Address list is empty",
                    description: "Tap + to add the first one."
                )
            } else {
                listView
            }
        }
        .navigationTitle(model.title)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    isPresentingContactAddressInput = model.input(from: nil)
                } label: {
                    Images.System.plus
                }
            }
        }
        .alert(
            "",
            isPresented: $presentingErrorMessage.mappedToBool(),
            actions: {},
            message: {
                Text(presentingErrorMessage ?? "")
            }
        )
        .confirmationDialog(
            Localized.Common.deleteConfirmation(addressToDelete?.value ?? ""),
            presenting: $addressToDelete,
            sensoryFeedback: .warning,
            actions: { address in
                Button(
                    Localized.Common.delete,
                    role: .destructive,
                    action: { didTapConfirmDelete(address: address) }
                )
            }
        )
    }
    
    private var listView: some View {
        List {
            Section {
                ForEach(model.buildListItemViews(addresses: addresses)) { item in
                    NavigationCustomLink(
                        with: ContactAddressListItemView(
                            address: item.address,
                            memo: item.memo,
                            chain: item.chain,
                            image: item.image?.image
                        )) {
                            didSelect(address: item.object)
                    }.swipeActions {
                        Button("Delete") {
                            didTapDelete(address: item.object)
                        }
                        .tint(Colors.red)
                    }
                }
            }
        }
        .background(Colors.grayBackground)
        
    }
}

// MARK: - Actions

extension ContactAddressListScene {
    private func didTapConfirmDelete(address: ContactAddress) {
        do {
            try model.delete(address: address)
        } catch {
            presentingErrorMessage = error.localizedDescription
        }
    }
    
    private func didSelect(address: ContactAddress) {
        isPresentingContactAddressInput = model.input(from: address)
    }
    
    private func didTapDelete(address: ContactAddress) {
        addressToDelete = address

    }
}
