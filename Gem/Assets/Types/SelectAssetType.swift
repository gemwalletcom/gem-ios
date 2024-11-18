import Foundation

enum SelectAssetType: Identifiable, Hashable {
    case send
    case receive
    case buy
    case sell
    case swap(SelectAssetSwapType)
    case stake
    case manage
    case priceAlert

    var id: String {
        switch self {
        case .send: "send"
        case .receive: "receive"
        case .buy: "buy"
        case .sell: "sell"
        case .swap(let type): "swap_\(type.id)"
        case .stake: "stake"
        case .manage: "manage"
        case .priceAlert:"priceAlert"
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
