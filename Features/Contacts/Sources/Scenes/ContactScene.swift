// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUICore
import SwiftUI
import PrimitivesComponents
import Components
import Primitives
import Style
import Localization
import NameResolver
import GRDB
import GRDBQuery
import Store

public struct ContactScene: View {
    @State private var model: ContactViewModel
    @State private var isPresentingErrorMessage: String?
    @State private var isPresentingNetworkSelector: Bool = false
    @State private var addressToDelete: ContactAddress? = .none

    @Binding private var isPresentingContactAddressViewType: ContactAddressViewType?

    @FocusState private var focusedField: Field?
    enum Field: Int, Hashable {
        case name
        case description
    }
    
    @Query<ContactAddressListRequest>
    private var addresses: [ContactAddress]
    
    public init(
        model: ContactViewModel,
        isPresentingContactAddressViewType: Binding<ContactAddressViewType?>
    ) {
        _isPresentingContactAddressViewType = isPresentingContactAddressViewType
        _model = State(initialValue: model)
        
        let request = Binding {
            model.addressesRequest
        } set: { new in
            model.addressesRequest = new
        }
        
        _addresses = Query(request)
    }
    
    @ViewBuilder
    public var body: some View {
        VStack {
            List {
                Section {
                    FloatTextField(
                        model.nameTitleField,
                        text: $model.projectedValue.input.name.value ?? "",
                        allowClean: true
                    )
                    .focused($focusedField, equals: .name)
                    .textInputAutocapitalization(.words)
                    .autocorrectionDisabled()
                    .submitLabel(.done)
                    
                    FloatTextField(
                        model.descriptionTitleField,
                        text: $model.projectedValue.input.description.value ?? "",
                        allowClean: true
                    )
                    .focused($focusedField, equals: .description)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .submitLabel(.done)
                }
                    Section {
                        Button(action: onSelectNewAddress) {
                             HStack {
                                 Images.Wallets.create
                                 Text("New address")
                             }
                        }
                        ForEach(model.buildListItemViews(addresses: addresses)) { item in
                            NavigationCustomLink(with: ListItemView(
                                title: item.address,
                                titleExtra: item.memo,
                                image: item.image?.image
                            )) {
                                isPresentingContactAddressViewType = .edit(address: item.object)
                            }
                            .swipeActions(edge: .trailing) {
                                Button(Localized.Common.delete) {
                                    onSelectDelete(on: item.object)
                                }
                                .tint(Colors.red)
                            }
                        }
                    } header: { Text("Addresses") }
            }
            Spacer()
            StateButton(
                text: model.actionButtonTitlte,
                styleState: .normal,
                action: onSelectSave
            )
            .frame(maxWidth: .scene.button.maxWidth)
        }
        .onAppear {
            if case .add = model.viewType {
                focusedField = .name
            }
        }
        .navigationTitle(model.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(model.cancelButtonTitle) {
                    model.onComplete?()
                }.bold()
            }
        }
        .padding(.bottom, .scene.bottom)
        .background(Colors.grayBackground)
        .listSectionSpacing(.compact)
        .alert(
            "",
            isPresented: $isPresentingErrorMessage.mappedToBool(),
            actions: {},
            message: {
                Text(isPresentingErrorMessage ?? "")
            }
        )
        .sheet(isPresented: $isPresentingNetworkSelector) {
            SelectableSheet(
                model: model.networksModel,
                onFinishSelection: { value in
                    onFinishChainSelection(chains: value)
                    isPresentingNetworkSelector = false
                },
                listContent: { ChainView(model: ChainViewModel(chain: $0)) }
            )
        }
        .confirmationDialog(
            Localized.Common.deleteConfirmation(addressToDelete?.address ?? ""),
            presenting: $addressToDelete,
            sensoryFeedback: .warning,
            actions: { address in
                Button(
                    Localized.Common.delete,
                    role: .destructive,
                    action: { onSelectConfirmDelete(address: address) }
                )
            }
        )
    }
}

// MARK: - Actions

extension ContactScene {
    private func onSelectNewAddress() {
        switch model.viewType {
        case .add:
            do {
                try model.save()
                fallthrough
            } catch {
                presentCreateError(error)
            }
        default:
            focusedField = nil
            isPresentingNetworkSelector = true
        }
    
    }
    private func onSelectConfirmDelete(address: ContactAddress) {
        do {
            try model.delete(address: address)
        } catch {
            isPresentingErrorMessage = error.localizedDescription
        }
    }
    
    private func onSelectDelete(on address: ContactAddress) {
        addressToDelete = address
    }
    
    private func onSelectSave() {
        do {
            try model.save()
            model.onComplete?()
        } catch {
            presentCreateError(error)
        }
    }
    
    private func onFinishChainSelection(chains: [Chain]) {
        guard let chain = chains.first, case .view(let contact) = model.viewType else {
            return
        }
        
        isPresentingContactAddressViewType = .add(contact: contact, chain: chain)
    }
    
    private func presentCreateError(_ error: Error) {
        if (error as? DatabaseError)?.extendedResultCode == .SQLITE_CONSTRAINT_UNIQUE {
            isPresentingErrorMessage = "Contact with this name is already exists."
        } else {
            isPresentingErrorMessage = error.localizedDescription
        }
    }
}
