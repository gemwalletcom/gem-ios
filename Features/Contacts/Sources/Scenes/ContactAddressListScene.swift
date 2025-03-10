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
    @State private var isPresentingErrorMessage: String?
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
        .overlay {
            if addresses.isEmpty {
                Text("No addresses yet")
                    .textStyle(.body)
            }
        }
        .background(Colors.insetGroupedListStyle)
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
            isPresented: $isPresentingErrorMessage.mappedToBool(),
            actions: {},
            message: {
                Text(isPresentingErrorMessage ?? "")
            }
        )
        .confirmationDialog(
            Localized.Common.deleteConfirmation(addressToDelete?.address ?? ""),
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
}

// MARK: - Actions

extension ContactAddressListScene {
    private func didTapConfirmDelete(address: ContactAddress) {
        do {
            try model.delete(address: address)
        } catch {
            isPresentingErrorMessage = error.localizedDescription
        }
    }
    
    private func didSelect(address: ContactAddress) {
        isPresentingContactAddressInput = model.input(from: address)
    }
    
    private func didTapDelete(address: ContactAddress) {
        addressToDelete = address

    }
}
