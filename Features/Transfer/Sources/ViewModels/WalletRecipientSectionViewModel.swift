// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import Components
import Formatters

struct WalletRecipientSectionViewModel {
    private let wallets: [Wallet]
    private let section: RecipientAddressType
    private let chain: Chain

    init(wallets: [Wallet], section: RecipientAddressType, chain: Chain) {
        self.wallets = wallets
        self.section = section
        self.chain = chain
    }

    var listItems: [ListItemValue<RecipientAddress>] {
        wallets
            .filter(walletFilter)
            .compactMap { wallet -> ListItemValue<RecipientAddress>? in
                guard let account = wallet.accounts.first(where: { $0.chain == chain }) else {
                    return nil
                }
                return ListItemValue(
                    title: wallet.name,
                    subtitle: AddressFormatter(address: account.address, chain: account.chain).value(),
                    value: RecipientAddress(name: wallet.name, address: account.address, memo: nil)
                )
            }
    }

    private func walletFilter(_ wallet: Wallet) -> Bool {
        switch section {
        case .view: wallet.type == .view && !wallet.isPinned && wallet.accounts.first?.chain == chain
        case .wallets: (wallet.type == .multicoin || wallet.type == .single) && !wallet.isPinned && wallet.accounts.contains { $0.chain == chain }
        case .pinned: wallet.isPinned && wallet.accounts.contains { $0.chain == chain }
        case .contacts: false
        }
    }
}
