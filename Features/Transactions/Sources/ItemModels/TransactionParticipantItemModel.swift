// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Components
import Primitives
import PrimitivesComponents

public struct TransactionParticipantItemModel {
    public let title: String
    public let account: SimpleAccount
    public let addressLink: BlockExplorerLink
    public let onAddContact: (() -> Void)?

    public init(
        title: String,
        account: SimpleAccount,
        addressLink: BlockExplorerLink,
        onAddContact: (() -> Void)? = nil
    ) {
        self.title = title
        self.account = account
        self.addressLink = addressLink
        self.onAddContact = onAddContact
    }

    public var addressViewModel: AddressListItemViewModel {
        AddressListItemViewModel(
            title: title,
            account: account,
            mode: .nameOrAddress,
            addressLink: addressLink,
            onAddContact: onAddContact
        )
    }
}
