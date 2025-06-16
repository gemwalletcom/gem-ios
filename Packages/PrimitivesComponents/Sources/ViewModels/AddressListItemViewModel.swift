// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Localization
import Components

public struct AddressListItemViewModel {
    
    public enum Mode {
        case auto(addressStyle: AddressFormatter.Style)
        case address(addressStyle: AddressFormatter.Style)
        case nameOrAddress
    }

    public let title: String
    public let account: SimpleAccount
    public let mode: Mode
    private let explorerService: ExplorerLinkFetchable

    public init(
        title: String,
        account: SimpleAccount,
        mode: Mode,
        explorerService: some ExplorerLinkFetchable
    ) {
        self.title = title
        self.account = account
        self.mode = mode
        self.explorerService = explorerService
    }

    public var subtitle: String {
        switch mode {
        case .auto(let style): auto(for: style)
        case .address(let style): address(for: style)
        case .nameOrAddress: account.name ?? account.address
        }
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
    
    // MARK: - Private methods
    
    private func auto(for style: AddressFormatter.Style) -> String {
        if account.name == account.address || account.name == nil {
            return address(for: style)
        } else if let _ = account.assetImage, let name = account.name {
            return name
        } else if let name = account.name {
            let address = address(for: .short)
            return "\(name) (\(address))"
        }
        return account.address
    }

    private func address(for style: AddressFormatter.Style) -> String {
        return AddressFormatter(style: style, address: account.address, chain: account.chain).value()
    }
}
