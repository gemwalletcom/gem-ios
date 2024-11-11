import Foundation

enum HeaderButtonType: String, Identifiable, CaseIterable {
    case send
    case receive
    case buy
    case sell
    case swap
    
    var id: String { rawValue }
}

extension HeaderButtonType {
    var selectType: SelectAssetType {
        switch self {
        case .receive: return .receive
        case .send: return .send
        case .buy: return .buy
        case .sell: return .sell
        case .swap: return .swap
        }
    }
}
