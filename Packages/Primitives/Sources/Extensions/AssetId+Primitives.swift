import Foundation

public extension AssetId {

    init(id: String) throws {
        if let (chain, tokenID) = AssetId.getData(id: id) {
            self.init(chain: chain, tokenId: tokenID)
        } else {
            throw AnyError("invalid asset id: \(id)")
        }
    }
    
    static func getData(id: String) -> (Chain, String?)? {
        let split = id.split(separator: "_")
        if split.count == 1  {
            if let chain = Chain(rawValue: id) {
                return (chain, .none)
            }
        } else if let underscoreIndex = id.firstIndex(of: "_") {
            let chain = String(id[..<underscoreIndex])
            let tokenId = String(id[id.index(after: underscoreIndex)...])
            if let chain = Chain(rawValue: chain) {
                return (chain, tokenId)
            }
        }
        return .none
    }
    
    var type: AssetSubtype {
        guard let tokenId = tokenId, !tokenId.isEmpty else {
            return .native
        }
        return .token
    }
    
    var identifier: String {
        switch type {
        case .native:
            return String(format: "%@", chain.rawValue)
        case .token:
            return String(format: "%@_%@", chain.rawValue, tokenId ?? "")
        }
    }
    
    var assetType: AssetType? {
        switch chain {
        case .ethereum,
            .polygon,
            .arbitrum,
            .optimism,
            .base,
            .avalancheC,
            .fantom,
            .gnosis,
            .manta,
            .blast,
            .zkSync,
            .linea,
            .mantle,
            .celo,
            .world: .erc20
        case .smartChain, .opBNB: .bep20
        case .solana: .spl
        case .tron: .trc20
        case .cosmos,
            .osmosis,
            .celestia,
            .injective,
            .sei,
            .noble: .ibc
        case .sui: .token
        case .ton: .jetton
        case .bitcoin,
            .litecoin,
            .thorchain,
            .doge,
            .aptos,
            .xrp,
            .near: .none
        }
    }
}
