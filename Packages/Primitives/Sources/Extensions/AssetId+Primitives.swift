import Foundation

extension AssetId: Identifiable {
    public var id: String { self.identifier }
}

public extension AssetId {

    static let subTokenSeparator = "::"
    
    init(id: String) throws {
        if let (chain, tokenID) = AssetId.getData(id: id) {
            self.init(chain: chain, tokenId: tokenID)
        } else {
            throw AnyError("invalid asset id: \(id)")
        }
    }
    
    init(chain: Chain) {
        self = .init(chain: chain, tokenId: .none)
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
    
    func twoSubTokenIds() throws -> (String, String) {
        guard let split = tokenId?.split(separator: Self.subTokenSeparator).map ({ String($0) }), split.count >= 2 else {
            throw AnyError("invalid token id: \(tokenId ?? "")")
        }
        return (
            try split.getElement(safe: 0),
            try split.getElement(safe: 1)
        )
    }
    
    static func subTokenId(_ ids: [String]) -> String {
        ids.joined(separator: subTokenSeparator)
    }
    
    func getTokenId() throws -> String {
        guard let tokenId = tokenId else {
            throw AnyError("tokenId is null")
        }
        return tokenId
    }
}
