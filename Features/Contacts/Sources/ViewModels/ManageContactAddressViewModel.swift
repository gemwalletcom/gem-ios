// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import SwiftUI
import Primitives
import PrimitivesComponents
import Validators
import GemstonePrimitives
import Components
import Style
import Localization
import WalletCorePrimitives

@Observable
@MainActor
public final class ManageContactAddressViewModel {
    public enum Mode: Identifiable {
        case add
        case edit(ContactAddress)

        public var id: String {
            switch self {
            case .add: "add"
            case .edit(let address): address.id
            }
        }

        var contactAddress: ContactAddress? {
            switch self {
            case .add: nil
            case .edit(let address): address
            }
        }
    }

    private let mode: Mode
    private let contactId: String
    private let onComplete: (ContactAddress) -> Void

    var addressInputModel: AddressInputViewModel
    var memo: String = ""
    var isPresentingScanner = false

    public init(
        contactId: String,
        nameService: any NameServiceable,
        mode: Mode,
        onComplete: @escaping (ContactAddress) -> Void
    ) {
        self.contactId = contactId
        self.mode = mode
        self.onComplete = onComplete
        self.title = Localized.Common.address

        let chain = mode.contactAddress?.chain ?? .bitcoin
        self.addressInputModel = AddressInputViewModel(
            chain: chain,
            nameService: nameService,
            placeholder: title,
            validators: [.required(requireName: title), .address(Asset(chain))]
        )

        if let address = mode.contactAddress {
            self.addressInputModel.text = address.address
            self.memo = address.memo ?? ""
        }
    }

    let title: String
    var buttonTitle: String { Localized.Transfer.confirm }
    var networkTitle: String { Localized.Transfer.network }
    var memoTitle: String { Localized.Transfer.memo }
    var chain: Chain { addressInputModel.chain }
    var showMemo: Bool { chain.isMemoSupported }

    var networkSelectorModel: NetworkSelectorViewModel {
        NetworkSelectorViewModel(
            state: .data(.plain(Chain.allCases)),
            selectedItems: [chain],
            selectionType: .checkmark
        )
    }

    var buttonState: ButtonState {
        addressInputModel.isValid ? .normal : .disabled
    }

    private var currentAddress: ContactAddress {
        ContactAddress.new(
            contactId: contactId,
            chain: chain,
            address: chain.checksumAddress(addressInputModel.resolvedAddress),
            memo: memo.isEmpty ? nil : memo
        )
    }
}

// MARK: - Actions

extension ManageContactAddressViewModel {
    func onSelectChain(_ chain: Chain) {
        addressInputModel.chain = chain
        self.memo = ""
    }

    func onSelectScan() {
        isPresentingScanner = true
    }

    func onHandleScan(_ result: String) {
        addressInputModel.update(text: result)
    }

    func complete() {
        guard addressInputModel.validate() else { return }
        onComplete(currentAddress)
    }
}
