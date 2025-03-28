// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Localization
import Components

public struct AddressListItemViewModel {
    public let title: String
    public let account: SimpleAccount
    public let style: AddressFormatter.Style
    private let explorerService: ExplorerLinkFetchable

    public init(
        title: String,
        account: SimpleAccount,
        style: AddressFormatter.Style,
        explorerService: some ExplorerLinkFetchable
    ) {
        self.title = title
        self.account = account
        self.style = style
        self.explorerService = explorerService
    }

    public var subtitle: String {
        if account.name == account.address || account.name == nil {
            return AddressFormatter(style: style, address: account.address, chain: account.chain).value()
        } else if let _ = account.assetImage, let name = account.name {
            return name
        } else if let name = account.name {
            let address = AddressFormatter(style: .short, address: account.address, chain: account.chain).value()
            return "\(name) (\(address))"
        }
        return account.address
    }
    
    public var assetImage: AssetImage? {
        account.assetImage
    }

    public var addressLink: BlockExplorerLink {
        explorerService.addressUrl(chain: account.chain, address: account.address)
    }

    public var addressExplorerText: String {
        Localized.Transaction.viewOn(addressLink.name)
    }

    public var addressExplorerUrl: URL {
        addressLink.url
    }
}
