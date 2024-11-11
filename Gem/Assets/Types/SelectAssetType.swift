import Foundation

enum SelectAssetType: String, Identifiable {
    case send
    case receive
    case buy
    case sell
    case swap
    case stake
    case manage
    case priceAlert

    var id: String {
        return rawValue
    }
}
