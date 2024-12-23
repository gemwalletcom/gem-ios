// Copyright (c). Gem Wallet. All rights reserved.

import SwiftUI
import Primitives
import GemstonePrimitives
import Components
import Style
import Localization

struct SimpleAccount {
    let name: String?
    let chain: Chain
    let address: String
    let assetImage: AssetImage?
}

struct AddressListItem: View {
    
    let title: String
    let style: AddressFormatter.Style
    let account: SimpleAccount

    var body: some View {
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
        ExplorerService.main.addressUrl(chain: account.chain, address: account.address)
    }
    var addressExplorerText: String { Localized.Transaction.viewOn(addressLink.name) }
    var addressExplorerUrl: URL { addressLink.url }
}
