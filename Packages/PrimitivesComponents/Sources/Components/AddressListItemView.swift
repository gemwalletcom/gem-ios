// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import Components
import Style
import Localization

// TODO: - remove explorerService dependency get address link in init
public struct AddressListItemView: View {
    let title: String
    let style: AddressFormatter.Style
    let account: SimpleAccount
    let explorerService: any ExplorerLinkFetchable

    public init(
        title: String,
        style: AddressFormatter.Style,
        account: SimpleAccount,
        explorerService: any ExplorerLinkFetchable
    ) {
        self.title = title
        self.style = style
        self.account = account
        self.explorerService = explorerService
    }

    public var body: some View {
        HStack {
            ListItemView(title: title, subtitle: subtitle)
            if let assetImage = account.assetImage {
                AssetImageView(assetImage: assetImage, size: Sizing.list.image)
            }
        }.contextMenu {
            ContextMenuCopy(title: Localized.Common.copy, value: account.address)
            ContextMenuViewURL(title: addressExplorerText, url: addressExplorerUrl, image: SystemImage.globe)
        }
    }
    
    var subtitle: String {
        if account.name == account.address || account.name == .none {
            return AddressFormatter(style: style, address: account.address, chain: account.chain).value()
        }
        return account.name ?? account.address
    }
    
    private var addressLink: BlockExplorerLink {
        explorerService.addressUrl(chain: account.chain, address: account.address)
    }

    var addressExplorerText: String { Localized.Transaction.viewOn(addressLink.name) }
    var addressExplorerUrl: URL { addressLink.url }
}
