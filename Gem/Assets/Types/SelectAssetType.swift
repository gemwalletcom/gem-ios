import Foundation

enum SelectAssetType: Identifiable, Hashable {
    case send
    case receive
    case buy
    case swap(SelectAssetSwapType)
    case stake
    case manage
    case priceAlert

    var id: String {
        switch self {
        case .send:
            return "send"
        case .receive:
            return "receive"
        case .buy:
            return "buy"
        case .swap(let type):
            return "swap_\(type.id)"
        case .stake:
            return "stake"
        case .manage:
            return "manage"
        case .priceAlert:
            return "priceAlert"
        }
    }
}


enum SelectAssetSwapType: String, Identifiable, Hashable {
    case pay
    case receive
    
    var id: String {
        return rawValue
    }
}
