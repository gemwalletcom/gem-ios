// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

extension Wallet: Identifiable {}

public extension Wallet {
    var canSign: Bool {
        !isViewOnly
    }

    var isViewOnly: Bool {
        return type == .view
    }

    var isMultiCoins: Bool {
        return type == .multicoin
    }

    var walletId: WalletId {
        WalletId(id: id)
    }

    func walletIdentifier() throws -> WalletIdentifier {
        switch type {
        case .multicoin:
            guard let address = accounts.first(where: { $0.chain == .ethereum })?.address else {
                throw AnyError("multicoin wallet requires an ethereum account")
            }
            return .multicoin(address: address)
        case .single, .privateKey, .view:
            guard let account = accounts.first else {
                throw AnyError("\(type) wallet requires at least one account")
            }
            return WalletIdentifier.make(walletType: type, chain: account.chain, address: account.address)
        }
    }

    var hasTokenSupport: Bool {
        accounts.map { $0.chain }.asSet().intersection(AssetConfiguration.supportedChainsWithTokens).isNotEmpty
    }

    func account(for chain: Chain) throws -> Account {
        guard let account = accounts.filter({ $0.chain == chain }).first else {
            throw AnyError("account not found for chain: \(chain.rawValue)")
        }
        return account
    }

    var perpetualAddress: String? {
        accounts.first { $0.chain == .arbitrum || $0.chain == .hyperCore || $0.chain == .hyperliquid }?.address
    }
}

// factory
public extension Wallet {
    static func makeView(name: String, chain: Chain, address: String) -> Wallet {
        return Wallet(
            id: NSUUID().uuidString,
            externalId: nil,
            name: name,
            index: 0,
            type: .view,
            accounts: [
                Account(
                    chain: chain,
                    address: address,
                    derivationPath: "",
                    extendedPublicKey: ""
                ),
            ],
            order: 0,
            isPinned: false,
            imageUrl: nil,
            source: .import
        )
    }
}
