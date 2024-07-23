import Foundation

enum HeaderButtonType: String, Identifiable, CaseIterable {
    case send
    case receive
    case buy
    case swap
    
    var id: String { rawValue }
}

extension HeaderButtonType {
    var selectType: SelectAssetType {
        switch self {
        case .receive: return .receive
        case .send: return .send
        case .buy: return .buy
        case .swap: return .swap
        }
    }
}
