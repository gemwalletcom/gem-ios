// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Components
import Primitives
import PrimitivesComponents

public struct TransactionParticipantItemModel {
    public let title: String
    public let account: SimpleAccount
    public let addressLink: BlockExplorerLink
    
    public init(
        title: String,
        account: SimpleAccount,
        addressLink: BlockExplorerLink
    ) {
        self.title = title
        self.account = account
        self.addressLink = addressLink
    }
    
    public var addressViewModel: AddressListItemViewModel {
        AddressListItemViewModel(
            title: title,
            account: account,
            mode: .nameOrAddress,
            addressLink: addressLink
        )
    }
}
