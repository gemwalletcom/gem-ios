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
    
    init(
        wallet: Wallet,
        service: AddTokenService
    ) {
        self.service = service
        self.wallet = wallet
    }
    
    var title: String {
        Localized.Wallet.AddToken.title
    }
    
    var defaultChain: Chain {
        chains.first!
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
    
    func getTokenData(chain: Chain, tokenId: String) async throws -> Asset {
        try await service.getTokenData(chain: chain, tokenId: tokenId)
    }
    
    func fetch(chain: Chain, tokenId: String) async throws {
        DispatchQueue.main.async {
            self.state = .loading
        }
        do {
            let asset = try await getTokenData(chain: chain, tokenId: tokenId)
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
