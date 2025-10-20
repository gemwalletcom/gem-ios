// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import class Gemstone.Config
import class Gemstone.Explorer
import Primitives
import GemstonePrimitives
import Preferences

public struct ExplorerService {
    private let preferences: any ExplorerPreferencesStorable

    public static let standard: ExplorerService = ExplorerService()

    public init(preferences: any ExplorerPreferencesStorable = ExplorerPreferences()) {
        self.preferences = preferences
    }

    private func explorerNameOrDefault(chain: Chain) -> String {
        let name = preferences.get(chain: chain)
        let explorers = Self.explorers(chain: chain)
        return explorers.first(where: { $0 == name }) ?? explorers.first!
    }

    public static func explorers(chain: Chain) -> [String] {
        Gemstone.Config.shared.getBlockExplorers(chain: chain.id)
    }

    public func transactionUrl(chain: Chain, hash: String) -> BlockExplorerLink {
        let name = explorerNameOrDefault(chain: chain)
        let explorer = Gemstone.Explorer(chain: chain.id)
        let url = URL(string: explorer.getTransactionUrl(explorerName: name, transactionId: hash))!
        return BlockExplorerLink(name: name, link: url.absoluteString)
    }

    public func swapTransactionUrl(chain: Chain, provider: String, identifier: String) -> BlockExplorerLink? {
        let name = explorerNameOrDefault(chain: chain)
        let explorer = Gemstone.Explorer(chain: chain.id)
        guard let url = explorer.getTransactionSwapUrl(
            explorerName: name,
            transactionId: identifier,
            providerId: provider
        ) else {
            return nil
        }
        return BlockExplorerLink(name: url.name, link: url.url)
    }

    public func addressUrl(chain: Chain, address: String) -> BlockExplorerLink {
        let name = explorerNameOrDefault(chain: chain)
        let explorer = Gemstone.Explorer(chain: chain.id)
        let url = URL(string: explorer.getAddressUrl(explorerName: name, address: address))!
        return BlockExplorerLink(name: name, link: url.absoluteString)
    }

    public func tokenUrl(chain: Chain, address: String) -> BlockExplorerLink? {
        let name = explorerNameOrDefault(chain: chain)
        let explorer = Gemstone.Explorer(chain: chain.id)
        if let tokenUrl = explorer.getTokenUrl(explorerName: name, address: address), let url = URL(string: tokenUrl) {
            return BlockExplorerLink(name: name, link: url.absoluteString)
        }
        return .none
    }

    public func validatorUrl(chain: Chain, address: String) -> BlockExplorerLink? {
        let name = explorerNameOrDefault(chain: chain)
        let explorer = Gemstone.Explorer(chain: chain.id)
        if let tokenUrl = explorer.getValidatorUrl(explorerName: name, address: address), let url = URL(
            string: tokenUrl
        ) {
            return BlockExplorerLink(name: name, link: url.absoluteString)
        }
        return .none
    }
}

// MARK: - ExplorerStorable

extension ExplorerService: ExplorerPreferencesStorable {
    public func set(chain: Chain, name: String) {
        preferences.set(chain: chain, name: name)
    }

    public func get(chain: Chain) -> String? {
        preferences.get(chain: chain)
    }
}

// MARK: - ExplorerLinkFetchable

extension ExplorerService: ExplorerLinkFetchable { }
