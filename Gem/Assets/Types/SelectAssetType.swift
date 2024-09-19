import Foundation

enum SelectAssetType: String, Identifiable {
    case send
    case receive
    case buy
    case swap
    case stake
    case manage
    case priceAlert

    var id: String {
        return rawValue
    }
}
