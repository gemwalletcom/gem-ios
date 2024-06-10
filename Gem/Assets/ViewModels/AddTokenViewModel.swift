// Copyright (c). Gem Wallet. All rights reserved.

import Foundation
import Primitives
import SwiftUI
import Settings
import Components

class AddTokenViewModel: ObservableObject {
    let wallet: Wallet
    let service: AddTokenService

    @Published var state: StateViewType<AddAssetViewModel> = .noData
    @Published var address: String
    @Published var chain: Chain?

    init(
        wallet: Wallet,
        service: AddTokenService,
        address: String = "",
        chain: Chain? = nil
    ) {
        self.service = service
        self.wallet = wallet
        self.address = address
        self.chain = chain
    }
    
    var title: String {
        Localized.Wallet.AddToken.title
    }
    
    var defaultChain: Chain? {
        chains.first
    }
    
    var chains: [Chain] {
        AssetConfiguration.supportedChainsWithTokens
            .asSet()
            .intersection(
                wallet.accounts.map { $0.chain }.asSet()
            ).asArray().sorted { chain1, chain2 in
                AssetScore.defaultRank(chain: chain1) > AssetScore.defaultRank(chain: chain2)
            }
    }
}

// MARK: - 

extension AddTokenViewModel {
    func fetch(tokenId: String) async throws {
        guard let chain = chain else { return }

        DispatchQueue.main.async {
            self.state = .loading
        }
        do {
            let asset = try await service.getTokenData(chain: chain, tokenId: tokenId)
            DispatchQueue.main.async {
                self.state = .loaded(AddAssetViewModel(asset: asset))
            }
        } catch {
            DispatchQueue.main.async {
                self.state = .error(error)
            }
        }
    }
}
