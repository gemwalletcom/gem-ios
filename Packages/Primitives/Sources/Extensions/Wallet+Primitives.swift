// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

extension Wallet: Identifiable { }

public extension Wallet {
    var isViewOnly: Bool {
        return type == .view
    }

    var isMultiCoins: Bool {
        return type == .multicoin
    }

    var walletId: WalletId {
        WalletId(id: id)
    }

    func account(for chain: Chain) throws -> Account {
        guard let account = accounts.filter({ $0.chain == chain }).first else {
            throw AnyError("account not found for chain: \(chain.rawValue)")
        }
        return account
    }
}

extension Wallet: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public static func == (lhs: Wallet, rhs: Wallet) -> Bool {
        return lhs.id == rhs.id
    }
}

// factory
public extension Wallet {
    static func makeView(name: String, chain: Chain, address: String) -> Wallet {
        return Wallet(
            id: NSUUID().uuidString,
            name: name,
            index: 0,
            type: .view,
            accounts: [
                Account(
                    chain: chain,
                    address: address,
                    derivationPath: "",
                    extendedPublicKey: ""
                )
            ],
            order: 0,
            isPinned: false
        )
    }
}
