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
}
