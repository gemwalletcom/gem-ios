// Copyright (c). Gem Wallet. All rights reserved.

import Foundation

extension Wallet: Identifiable { }

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

    var walletIdType: String? {
        let value: String? = switch type {
        case .multicoin: accounts.first?.address
        case .single, .privateKey, .view: accounts.first.map { "\($0.chain.rawValue)_\($0.address)" }
        }
        return value.map { "\(type.rawValue)_\($0)" }
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
            isPinned: false,
            imageUrl: nil,
            source: .import
        )
    }
}
